-- ==============================================================================
-- 05_search_intent_wasted_spend.sql
-- Description: Quantifies wasted ad spend on zero-conversion SKUs and low-intent
--              traffic during the mature 30-day window.
-- Dataset: `quantacusinterviewproject.interview_ayad`
-- ==============================================================================

DECLARE max_available_date DATE;
DECLARE lag_exclusion_days INT64 DEFAULT 14;
DECLARE baseline_window_days INT64 DEFAULT 30;

DECLARE mature_end_date DATE;
DECLARE mature_start_date DATE;

SET max_available_date = (
  SELECT MAX(segments_date) 
  FROM `quantacusinterviewproject.interview_ayad.p_ads_ShoppingProductStats`
);

SET mature_end_date = DATE_SUB(max_available_date, INTERVAL lag_exclusion_days DAY);
SET mature_start_date = DATE_SUB(mature_end_date, INTERVAL (baseline_window_days - 1) DAY);

WITH SKU_Performance AS (
  SELECT
    segments_product_item_id AS product_item_id,
    SUM(metrics_clicks) AS clicks,
    SUM(metrics_impressions) AS impressions,
    ROUND(SUM(metrics_cost_micros / 1000000.0), 2) AS spend,
    ROUND(SUM(metrics_conversions), 2) AS conversions,
    ROUND(SUM(metrics_conversions_value), 2) AS conversion_value
  FROM `quantacusinterviewproject.interview_ayad.p_ads_ShoppingProductStats`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
  GROUP BY segments_product_item_id
)

SELECT
  COUNT(DISTINCT product_item_id) AS total_active_skus,
  
  -- Overall Portfolio Totals
  ROUND(SUM(spend), 2) AS total_portfolio_spend,
  ROUND(SUM(conversion_value), 2) AS total_portfolio_revenue,
  
  -- Zero Conversion Bleeders
  COUNTIF(conversions = 0 AND spend > 0) AS zero_conversion_skus,
  ROUND(SUM(CASE WHEN conversions = 0 THEN spend ELSE 0 END), 2) AS zero_conversion_wasted_spend,
  ROUND(SAFE_DIVIDE(SUM(CASE WHEN conversions = 0 THEN spend ELSE 0 END), SUM(spend)) * 100, 2) AS wasted_spend_pct,
  
  -- High-Engagement Zero Conversion Bleeders (>= 20 clicks without a sale)
  COUNTIF(conversions = 0 AND clicks >= 20) AS high_click_zero_conv_skus,
  ROUND(SUM(CASE WHEN conversions = 0 AND clicks >= 20 THEN spend ELSE 0 END), 2) AS high_click_wasted_spend,
  
  -- Converting SKUs Core Baseline
  COUNTIF(conversions > 0) AS converting_skus,
  ROUND(SUM(CASE WHEN conversions > 0 THEN spend ELSE 0 END), 2) AS converting_skus_spend,
  ROUND(SAFE_DIVIDE(SUM(CASE WHEN conversions > 0 THEN conversion_value ELSE 0 END), 
                    SUM(CASE WHEN conversions > 0 THEN spend ELSE 0 END)), 3) AS converting_skus_roas

FROM SKU_Performance;