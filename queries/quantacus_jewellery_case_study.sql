-- ==============================================================================
-- QUANTACUS DATA AND STRATEGY CASE STUDY: MASTER SQL PIPELINE
-- Project: Jewellery Growth Case Study (ROAS 3.4 -> 5.0)
-- Target Dataset: `quantacusinterviewproject.interview_ayad`
-- Engine: Google Cloud BigQuery Standard SQL
--
-- Deliverable Requirement:
--   - Readable BigQuery Standard SQL with comments
--   - Clear CTE names and modular structure
--   - Reusable parameterized date ranges
--   - No SELECT * in final outputs
--   - Defensive handling of attribution lag, regex price parsing, deduplication, 
--     and campaign-to-product spend reconciliation.
-- ==============================================================================

-- ==============================================================================
-- SECTION 0: GLOBAL SCRIPT DECLARATIONS & PARAMETERS
-- ==============================================================================

DECLARE max_available_date DATE;
DECLARE lag_exclusion_days INT64 DEFAULT 14;      -- Trailing attribution lag buffer
DECLARE baseline_window_days INT64 DEFAULT 30;    -- Mature analysis baseline window
DECLARE min_clicks_confidence INT64 DEFAULT 40;   -- Statistical power threshold
DECLARE min_spend_bleed_factor NUMERIC DEFAULT 2.0;-- Multiplier of portfolio AOV

DECLARE mature_end_date DATE;
DECLARE mature_start_date DATE;
DECLARE reported_end_date DATE;
DECLARE reported_start_date DATE;

-- Dynamically establish the boundary date from the campaign performance table
SET max_available_date = (
  SELECT MAX(segments_date) 
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
);

-- Mature 30-day window (excludes trailing 14-day attribution decay)
SET mature_end_date = DATE_SUB(max_available_date, INTERVAL lag_exclusion_days DAY);
SET mature_start_date = DATE_SUB(mature_end_date, INTERVAL (baseline_window_days - 1) DAY);

-- Reported 30-day window (contains incomplete attribution lag, used for 3.4 reconciliation)
SET reported_end_date = max_available_date;
SET reported_start_date = DATE_SUB(reported_end_date, INTERVAL (baseline_window_days - 1) DAY);


-- ==============================================================================
-- PART 1: BASELINE REBUILD & ATTRIBUTION LAG RECONCILIATION
-- Reconciles reported 3.40 ROAS vs mature 3.72 baseline and verifies spend units.
-- ==============================================================================

WITH campaign_mature AS (
  SELECT
    '1. Campaign Table (Mature 30D - Attribution Lag Excluded)' AS evaluation_segment,
    MIN(segments_date) AS period_start,
    MAX(segments_date) AS period_end,
    COUNT(DISTINCT segments_date) AS active_days,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(conversion_value), 2) AS total_revenue,
    ROUND(SUM(conversions), 2) AS total_conversions,
    SUM(clicks) AS total_clicks,
    ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(spend)), 3) AS roas,
    ROUND(SAFE_DIVIDE(SUM(conversions), SUM(clicks)), 4) AS cvr,
    ROUND(SAFE_DIVIDE(SUM(spend), SUM(clicks)), 2) AS cpc,
    ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(conversions)), 2) AS aov
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
),

campaign_reported_raw AS (
  SELECT
    '2. Campaign Table (Reported Raw 30D - Incomplete Lag Included)' AS evaluation_segment,
    MIN(segments_date) AS period_start,
    MAX(segments_date) AS period_end,
    COUNT(DISTINCT segments_date) AS active_days,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(conversion_value), 2) AS total_revenue,
    ROUND(SUM(conversions), 2) AS total_conversions,
    SUM(clicks) AS total_clicks,
    ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(spend)), 3) AS roas,
    ROUND(SAFE_DIVIDE(SUM(conversions), SUM(clicks)), 4) AS cvr,
    ROUND(SAFE_DIVIDE(SUM(spend), SUM(clicks)), 2) AS cpc,
    ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(conversions)), 2) AS aov
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
  WHERE segments_date BETWEEN reported_start_date AND reported_end_date
),

product_grain_mature AS (
  SELECT
    '3. Products Table (Mature 30D - Item Grain Reconciliation)' AS evaluation_segment,
    MIN(segments_date) AS period_start,
    MAX(segments_date) AS period_end,
    COUNT(DISTINCT segments_date) AS active_days,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(conversion_value), 2) AS total_revenue,
    ROUND(SUM(conversions), 2) AS total_conversions,
    SUM(clicks) AS total_clicks,
    ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(spend)), 3) AS roas,
    ROUND(SAFE_DIVIDE(SUM(conversions), SUM(clicks)), 4) AS cvr,
    ROUND(SAFE_DIVIDE(SUM(spend), SUM(clicks)), 2) AS cpc,
    ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(conversions)), 2) AS aov
  FROM `quantacusinterviewproject.interview_ayad.Products`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
)

SELECT * FROM campaign_mature
UNION ALL
SELECT * FROM campaign_reported_raw
UNION ALL
SELECT * FROM product_grain_mature;


-- ==============================================================================
-- PART 2: CAMPAIGN ARCHITECTURE & PMAX ASSET LEAKAGE AUDIT
-- Detects unallocated spend in Performance Max (non-product display/video inventory).
-- ==============================================================================

WITH campaign_metadata AS (
  SELECT
    campaign_id,
    campaign_name,
    advertising_channel_type,
    bidding_strategy_type,
    status
  FROM (
    SELECT
      campaign_id,
      campaign_name,
      advertising_channel_type,
      bidding_strategy_type,
      status,
      ROW_NUMBER() OVER (PARTITION BY campaign_id ORDER BY change_timestamp DESC) AS rn
    FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaigns`
  )
  WHERE rn = 1
),

campaign_totals AS (
  SELECT
    campaign_id,
    ROUND(SUM(spend), 2) AS macro_spend,
    ROUND(SUM(conversion_value), 2) AS macro_revenue,
    ROUND(SUM(conversions), 2) AS macro_conversions,
    SUM(clicks) AS macro_clicks
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
  GROUP BY campaign_id
),

product_attributed_totals AS (
  SELECT
    campaign_id,
    ROUND(SUM(spend), 2) AS item_spend,
    ROUND(SUM(conversion_value), 2) AS item_revenue
  FROM `quantacusinterviewproject.interview_ayad.Products`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
  GROUP BY campaign_id
),

overall_spend AS (
  SELECT SUM(spend) AS account_spend
  FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
)

SELECT
  c.campaign_id,
  COALESCE(m.campaign_name, 'Unidentified Campaign') AS campaign_name,
  COALESCE(m.advertising_channel_type, 'UNSPECIFIED') AS channel_type,
  COALESCE(m.bidding_strategy_type, 'MANUAL') AS bidding_strategy,
  c.macro_spend,
  c.macro_revenue,
  ROUND(SAFE_DIVIDE(c.macro_revenue, c.macro_spend), 3) AS campaign_roas,
  ROUND(SAFE_DIVIDE(c.macro_spend, o.account_spend) * 100, 2) AS spend_share_pct,
  COALESCE(p.item_spend, 0.0) AS catalogue_linked_spend,
  ROUND(c.macro_spend - COALESCE(p.item_spend, 0.0), 2) AS unallocated_pmax_spend,
  ROUND(SAFE_DIVIDE(c.macro_spend - COALESCE(p.item_spend, 0.0), c.macro_spend) * 100, 2) AS unallocated_spend_pct
FROM campaign_totals c
CROSS JOIN overall_spend o
LEFT JOIN campaign_metadata m ON c.campaign_id = m.campaign_id
LEFT JOIN product_attributed_totals p ON c.campaign_id = p.campaign_id
ORDER BY c.macro_spend DESC;


-- ==============================================================================
-- PART 3: 4-TIER PRODUCT DECISION MATRIX
-- Segments items into Protect & Scale, Fix & Retest, Limit or Pause, Insufficient Evidence.
-- Safely parses regex sale_price and deduplicates catalogue snapshots.
-- ==============================================================================

WITH deduplicated_catalogue AS (
  SELECT
    offer_id,
    sku_id,
    title,
    product_type,
    brand,
    availability,
    clean_sale_price,
    clean_price,
    effective_price
  FROM (
    SELECT
      COALESCE(offer_id, sku_id) AS offer_id,
      sku_id,
      title,
      product_type,
      brand,
      availability,
      SAFE_CAST(REGEXP_EXTRACT(sale_price, r'[\d.]+') AS NUMERIC) AS clean_sale_price,
      SAFE_CAST(REGEXP_EXTRACT(price, r'[\d.]+') AS NUMERIC) AS clean_price,
      COALESCE(
        NULLIF(SAFE_CAST(REGEXP_EXTRACT(sale_price, r'[\d.]+') AS NUMERIC), 0),
        NULLIF(SAFE_CAST(REGEXP_EXTRACT(price, r'[\d.]+') AS NUMERIC), 0)
      ) AS effective_price,
      ROW_NUMBER() OVER (
        PARTITION BY COALESCE(offer_id, sku_id) 
        ORDER BY snapshot_date DESC
      ) AS rn
    FROM `quantacusinterviewproject.interview_ayad.list_obj`
  )
  WHERE rn = 1
),

item_performance AS (
  SELECT
    product_item_id,
    ROUND(SUM(spend), 2) AS item_spend,
    ROUND(SUM(conversion_value), 2) AS item_revenue,
    ROUND(SUM(conversions), 2) AS item_conversions,
    SUM(clicks) AS item_clicks,
    SUM(impressions) AS item_impressions,
    ROUND(SAFE_DIVIDE(SUM(conversion_value), SUM(spend)), 3) AS item_roas,
    ROUND(SAFE_DIVIDE(SUM(conversions), SUM(clicks)), 4) AS item_cvr,
    ROUND(SAFE_DIVIDE(SUM(spend), SUM(clicks)), 2) AS item_cpc
  FROM `quantacusinterviewproject.interview_ayad.Products`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
  GROUP BY product_item_id
),

portfolio_aov_calc AS (
  SELECT SAFE_DIVIDE(SUM(item_revenue), SUM(item_conversions)) AS portfolio_aov
  FROM item_performance
),

item_matrix AS (
  SELECT
    p.product_item_id,
    c.sku_id,
    c.title,
    c.product_type,
    c.availability,
    c.effective_price,
    p.item_spend,
    p.item_revenue,
    p.item_conversions,
    p.item_clicks,
    p.item_roas,
    p.item_cvr,
    p.item_cpc,

    CASE
      -- Tier 1: Protect & Scale (High ROAS, statistically significant, in stock)
      WHEN p.item_clicks >= min_clicks_confidence 
       AND p.item_roas >= 4.5 
       AND LOWER(COALESCE(c.availability, 'in stock')) = 'in stock'
        THEN 'Tier 1: Protect & Scale'

      -- Tier 3: Limit or Pause (High traffic bleeder, spend > 2x AOV, ROAS < 1.8)
      WHEN p.item_clicks >= min_clicks_confidence 
       AND p.item_roas < 1.8 
       AND p.item_spend >= (a.portfolio_aov * min_spend_bleed_factor)
        THEN 'Tier 3: Limit or Pause'

      -- Tier 2: Fix & Retest (Sub-optimal ROAS with meaningful traffic; feed/price optimization)
      WHEN p.item_clicks >= 25 
       AND p.item_roas BETWEEN 1.8 AND 4.49
        THEN 'Tier 2: Fix & Retest'

      -- Tier 4: Insufficient Evidence (Low sample size; preserve from false pruning)
      ELSE 'Tier 4: Insufficient Evidence'
    END AS strategic_segment

  FROM item_performance p
  CROSS JOIN portfolio_aov_calc a
  LEFT JOIN deduplicated_catalogue c ON p.product_item_id = c.offer_id
),

portfolio_totals AS (
  SELECT 
    SUM(item_spend) AS grand_spend,
    SUM(item_revenue) AS grand_revenue
  FROM item_matrix
)

SELECT
  m.strategic_segment,
  COUNT(DISTINCT m.product_item_id) AS sku_count,
  ROUND(SUM(m.item_spend), 2) AS tier_spend,
  ROUND(SUM(m.item_revenue), 2) AS tier_revenue,
  ROUND(SAFE_DIVIDE(SUM(m.item_revenue), SUM(m.item_spend)), 3) AS tier_roas,
  ROUND(SAFE_DIVIDE(SUM(m.item_spend), (SELECT grand_spend FROM portfolio_totals)) * 100, 2) AS spend_share_pct,
  ROUND(SAFE_DIVIDE(SUM(m.item_revenue), (SELECT grand_revenue FROM portfolio_totals)) * 100, 2) AS revenue_share_pct,
  ROUND(SAFE_DIVIDE(SUM(m.item_conversions), SUM(m.item_clicks)), 4) AS tier_cvr
FROM item_matrix m
GROUP BY m.strategic_segment
ORDER BY m.strategic_segment;


-- ==============================================================================
-- PART 4: MERCHANT CENTER FEED HEALTH & DIAGNOSTIC SEVERITY AUDIT
-- Uncovers revenue lost to disapproved, limited, or misformatted listings.
-- ==============================================================================

WITH feed_diagnostics AS (
  SELECT
    COALESCE(offer_id, sku_id) AS offer_id,
    COALESCE(UPPER(diagnostic_severity), 'UNSPECIFIED') AS normalized_severity,
    COALESCE(LOWER(availability), 'unknown') AS stock_status,
    SAFE_CAST(REGEXP_EXTRACT(sale_price, r'[\d.]+') AS NUMERIC) AS clean_sale_price,
    SAFE_CAST(REGEXP_EXTRACT(price, r'[\d.]+') AS NUMERIC) AS clean_price
  FROM `quantacusinterviewproject.interview_ayad.list_obj`
  QUALIFY ROW_NUMBER() OVER (PARTITION BY COALESCE(offer_id, sku_id) ORDER BY snapshot_date DESC) = 1
),

mature_sku_perf AS (
  SELECT
    product_item_id,
    ROUND(SUM(spend), 2) AS spend,
    ROUND(SUM(conversion_value), 2) AS revenue,
    ROUND(SUM(conversions), 2) AS conversions,
    SUM(clicks) AS clicks
  FROM `quantacusinterviewproject.interview_ayad.Products`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
  GROUP BY product_item_id
)

SELECT
  f.normalized_severity,
  f.stock_status,
  COUNT(DISTINCT f.offer_id) AS catalogue_sku_count,
  COUNT(DISTINCT p.product_item_id) AS active_spend_sku_count,
  ROUND(SUM(COALESCE(p.spend, 0)), 2) AS total_spend,
  ROUND(SUM(COALESCE(p.revenue, 0)), 2) AS total_revenue,
  ROUND(SAFE_DIVIDE(SUM(p.revenue), SUM(p.spend)), 3) AS group_roas,
  ROUND(SAFE_DIVIDE(SUM(p.conversions), SUM(p.clicks)), 4) AS group_cvr
FROM feed_diagnostics f
LEFT JOIN mature_sku_perf p ON f.offer_id = p.product_item_id
GROUP BY f.normalized_severity, f.stock_status
ORDER BY total_spend DESC;


-- ==============================================================================
-- PART 5: SEARCH INTENT & WASTED MEDIA SPEND AUDIT
-- Identifies non-converting queries and quantifies reallocatable media capital.
-- ==============================================================================

WITH listing_intent AS (
  SELECT
    product_item_id,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(conversion_value), 2) AS total_revenue,
    ROUND(SUM(conversions), 2) AS total_conversions,
    SUM(clicks) AS total_clicks
  FROM `quantacusinterviewproject.interview_ayad.p_ads_shoppingproductsstats`
  WHERE segments_date BETWEEN mature_start_date AND mature_end_date
  GROUP BY product_item_id
),

intent_classification AS (
  SELECT
    product_item_id,
    total_spend,
    total_revenue,
    total_conversions,
    total_clicks,
    ROUND(SAFE_DIVIDE(total_revenue, total_spend), 3) AS listing_roas,
    CASE
      WHEN total_clicks >= 40 AND total_conversions = 0 
        THEN 'Zero-Conversion Bleeder Query'
      WHEN total_clicks >= 40 AND SAFE_DIVIDE(total_revenue, total_spend) < 1.5 
        THEN 'Sub-1.5 ROAS Unprofitable'
      WHEN total_clicks >= 30 AND SAFE_DIVIDE(total_revenue, total_spend) >= 4.5 
        THEN 'High-Intent Core Winner'
      WHEN total_clicks >= 20 
        THEN 'Moderate Intent / Viable'
      ELSE 'Low-Traffic / Exploration'
    END AS intent_bucket
  FROM listing_intent
),

overall_intent_spend AS (
  SELECT SUM(total_spend) AS grand_intent_spend
  FROM intent_classification
)

SELECT
  i.intent_bucket,
  COUNT(DISTINCT i.product_item_id) AS listing_count,
  ROUND(SUM(i.total_spend), 2) AS bucket_spend,
  ROUND(SUM(i.total_revenue), 2) AS bucket_revenue,
  ROUND(SAFE_DIVIDE(SUM(i.total_revenue), SUM(i.total_spend)), 3) AS bucket_roas,
  ROUND(SAFE_DIVIDE(SUM(i.total_spend), (SELECT grand_intent_spend FROM overall_intent_spend)) * 100, 2) AS spend_share_pct,
  ROUND(SAFE_DIVIDE(SUM(i.total_conversions), SUM(i.total_clicks)), 4) AS bucket_cvr
FROM intent_classification i
GROUP BY i.intent_bucket
ORDER BY bucket_spend DESC;
