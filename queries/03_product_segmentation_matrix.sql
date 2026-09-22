-- ==============================================================================
-- 03_product_segmentation_matrix.sql
-- Description: Segments active SKUs into 4 actionable performance tiers
--              during the mature 30-day window based on click volume & ROAS.
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

WITH SKU_Aggregates AS (
  SELECT
    segments_product_item_id AS product_item_id,
    SUM(metrics_clicks) AS clicks,
    SUM(metrics_impressions) AS impressions,
    ROUND(SUM(metrics_cost_micros / 1000000.0), 2) AS spend,
    ROUND(SUM(metrics_conversions), 2) AS conversions,
    ROUND(SUM(metrics_conversions_value), 2) AS conversion_value,
    ROUND(SAFE_DIVIDE(SUM(metrics_conversions_value), SUM(metrics_cost_micros / 1000000.0)), 3) AS sku_roas
  FROM `quantacusinterviewproject.interview_ayad.p_ads_ShoppingProductStats`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
  GROUP BY segments_product_item_id
),

SKU_Tiers AS (
  SELECT
    *,
    CASE
      -- Tier 1: Statistically confident high performers
      WHEN clicks >= 40 AND sku_roas >= 4.0 THEN 'Tier 1: Protect & Scale'
      
      -- Tier 2: Statistically confident underperformers
      WHEN clicks >= 40 AND sku_roas BETWEEN 2.0 AND 3.999 THEN 'Tier 2: Fix & Retest'
      
      -- Tier 3: High-confidence value destroyers
      WHEN clicks >= 40 AND sku_roas < 2.0 THEN 'Tier 3: Limit or Pause'
      
      -- Tier 4: Low traffic / insufficient evidence
      ELSE 'Tier 4: Insufficient Evidence'
    END AS tier_group
  FROM SKU_Aggregates
)

SELECT
  tier_group,
  COUNT(DISTINCT product_item_id) AS sku_count,
  SUM(clicks) AS total_clicks,
  SUM(impressions) AS total_impressions,
  ROUND(SUM(spend), 2) AS total_spend,
  ROUND(SUM(conversion_value), 2) AS total_revenue,
  ROUND(SUM(conversions), 2) AS total_conversions,
  
  -- Performance Ratios
  ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(spend)), 3) AS tier_roas,
  ROUND(SAFE_DIVIDE(SUM(spend), SUM(conversions)), 2) AS cost_per_order,
  ROUND(SAFE_DIVIDE(SUM(conversions), SUM(clicks)), 4) AS tier_cvr,
  
  -- Portfolio Share
  ROUND(SAFE_DIVIDE(SUM(spend), SUM(SUM(spend)) OVER()) * 100, 2) AS spend_share_pct,
  ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(SUM(conversion_value)) OVER()) * 100, 2) AS revenue_share_pct

FROM SKU_Tiers
GROUP BY tier_group
ORDER BY total_spend DESC;