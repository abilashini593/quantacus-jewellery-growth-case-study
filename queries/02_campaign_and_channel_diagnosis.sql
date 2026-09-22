-- ==============================================================================
-- 02_campaign_and_channel_diagnosis.sql
-- Description: Multi-part diagnosis covering campaign-level performance 
--              and network placement rollups over the mature 30-day baseline.
-- Dataset: `quantacusinterviewproject.interview_ayad`
-- ==============================================================================

DECLARE max_available_date DATE;
DECLARE lag_exclusion_days INT64 DEFAULT 14;
DECLARE baseline_window_days INT64 DEFAULT 30;

DECLARE mature_end_date DATE;
DECLARE mature_start_date DATE;

SET max_available_date = (
  SELECT MAX(segments_date) 
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
);

SET mature_end_date = DATE_SUB(max_available_date, INTERVAL lag_exclusion_days DAY);
SET mature_start_date = DATE_SUB(mature_end_date, INTERVAL (baseline_window_days - 1) DAY);

-- ------------------------------------------------------------------------------
-- Part 1: Campaign Performance Breakdown
-- ------------------------------------------------------------------------------
SELECT
  campaign_base_campaign AS campaign_name,
  segments_ad_network_type AS network_type,
  SUM(metrics_clicks) AS total_clicks,
  SUM(metrics_impressions) AS total_impressions,
  ROUND(SUM(metrics_cost_micros / 1000000.0), 2) AS total_spend,
  ROUND(SUM(metrics_conversions_value), 2) AS total_conversion_value,
  ROUND(SUM(metrics_conversions), 2) AS total_conversions,
  ROUND(SAFE_DIVIDE(SUM(metrics_conversions_value), SUM(metrics_cost_micros / 1000000.0)), 3) AS roas,
  ROUND(SAFE_DIVIDE(SUM(metrics_cost_micros / 1000000.0), SUM(metrics_conversions)), 2) AS cpo
FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
WHERE segments_date BETWEEN mature_start_date AND mature_end_date
GROUP BY 1, 2
ORDER BY total_spend DESC;

-- ------------------------------------------------------------------------------
-- Part 2: Network Placement Breakdown (Executed Output)
-- ------------------------------------------------------------------------------
SELECT
  segments_ad_network_type AS network_type,
  COUNT(DISTINCT campaign_id) AS active_campaigns,
  SUM(metrics_clicks) AS total_clicks,
  SUM(metrics_impressions) AS total_impressions,
  ROUND(SUM(metrics_cost_micros / 1000000.0), 2) AS network_spend,
  ROUND(SUM(metrics_conversions_value), 2) AS network_revenue,
  ROUND(SUM(metrics_conversions), 2) AS network_conversions,
  ROUND(SAFE_DIVIDE(SUM(metrics_conversions_value), SUM(metrics_cost_micros / 1000000.0)), 3) AS network_roas,
  ROUND(SAFE_DIVIDE(SUM(metrics_conversions), SUM(metrics_clicks)), 4) AS network_cvr,
  ROUND(SAFE_DIVIDE(SUM(metrics_cost_micros / 1000000.0), SUM(metrics_clicks)), 2) AS network_cpc
FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
WHERE segments_date BETWEEN mature_start_date AND mature_end_date
GROUP BY network_type
ORDER BY network_spend DESC;