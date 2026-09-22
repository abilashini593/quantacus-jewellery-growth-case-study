-- ==============================================================================
-- 01_baseline_and_reconciliation.sql
-- Description: Establishes baseline metrics and reconciles mature 30D vs reported 30D
--              across campaign-level tables.
-- Dataset: `quantacusinterviewproject.interview_ayad`
-- ==============================================================================

DECLARE max_available_date DATE;
DECLARE lag_exclusion_days INT64 DEFAULT 14;
DECLARE baseline_window_days INT64 DEFAULT 30;

DECLARE mature_end_date DATE;
DECLARE mature_start_date DATE;
DECLARE reported_end_date DATE;
DECLARE reported_start_date DATE;

SET max_available_date = (
  SELECT MAX(segments_date) 
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
);

SET mature_end_date = DATE_SUB(max_available_date, INTERVAL lag_exclusion_days DAY);
SET mature_start_date = DATE_SUB(mature_end_date, INTERVAL (baseline_window_days - 1) DAY);

SET reported_end_date = max_available_date;
SET reported_start_date = DATE_SUB(reported_end_date, INTERVAL (baseline_window_days - 1) DAY);

WITH campaign_stats_mature AS (
  SELECT
    'Campaign Table (Mature 30D)' AS grain_level,
    MIN(segments_date) AS min_date,
    MAX(segments_date) AS max_date,
    COUNT(DISTINCT segments_date) AS total_days,
    ROUND(SUM(metrics_cost_micros / 1000000.0), 2) AS total_spend,
    ROUND(SUM(metrics_conversions_value), 2) AS total_conversion_value,
    ROUND(SUM(metrics_conversions), 2) AS total_conversions,
    SUM(metrics_clicks) AS total_clicks,
    SUM(metrics_impressions) AS total_impressions,
    ROUND(SAFE_DIVIDE(SUM(metrics_conversions_value), SUM(metrics_cost_micros / 1000000.0)), 3) AS blended_roas,
    ROUND(SAFE_DIVIDE(SUM(metrics_cost_micros / 1000000.0), SUM(metrics_conversions)), 2) AS cost_per_order,
    ROUND(SAFE_DIVIDE(SUM(metrics_conversions_value), SUM(metrics_conversions)), 2) AS average_order_value,
    ROUND(SAFE_DIVIDE(SUM(metrics_clicks), SUM(metrics_impressions)), 4) AS ctr,
    ROUND(SAFE_DIVIDE(SUM(metrics_conversions), SUM(metrics_clicks)), 4) AS cvr,
    ROUND(SAFE_DIVIDE(SUM(metrics_cost_micros / 1000000.0), SUM(metrics_clicks)), 2) AS cpc
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
),

campaign_stats_reported_raw AS (
  SELECT
    'Campaign Table (Reported Raw 30D with Lag)' AS grain_level,
    MIN(segments_date) AS min_date,
    MAX(segments_date) AS max_date,
    COUNT(DISTINCT segments_date) AS total_days,
    ROUND(SUM(metrics_cost_micros / 1000000.0), 2) AS total_spend,
    ROUND(SUM(metrics_conversions_value), 2) AS total_conversion_value,
    ROUND(SUM(metrics_conversions), 2) AS total_conversions,
    SUM(metrics_clicks) AS total_clicks,
    SUM(metrics_impressions) AS total_impressions,
    ROUND(SAFE_DIVIDE(SUM(metrics_conversions_value), SUM(metrics_cost_micros / 1000000.0)), 3) AS blended_roas,
    ROUND(SAFE_DIVIDE(SUM(metrics_cost_micros / 1000000.0), SUM(metrics_conversions)), 2) AS cost_per_order,
    ROUND(SAFE_DIVIDE(SUM(metrics_conversions_value), SUM(metrics_conversions)), 2) AS average_order_value,
    ROUND(SAFE_DIVIDE(SUM(metrics_clicks), SUM(metrics_impressions)), 4) AS ctr,
    ROUND(SAFE_DIVIDE(SUM(metrics_conversions), SUM(metrics_clicks)), 4) AS cvr,
    ROUND(SAFE_DIVIDE(SUM(metrics_cost_micros / 1000000.0), SUM(metrics_clicks)), 2) AS cpc
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
  WHERE segments_date BETWEEN reported_start_date AND reported_end_date
)

SELECT * FROM campaign_stats_mature
UNION ALL
SELECT * FROM campaign_stats_reported_raw;