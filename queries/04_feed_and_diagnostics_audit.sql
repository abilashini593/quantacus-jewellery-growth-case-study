-- ==============================================================================
-- 04_feed_and_diagnostics_audit.sql
-- Description: Evaluates Merchant Center feed health, auditing item availability,
--              missing price points, sale price coverage, and catalog attributes.
-- Dataset: `quantacusinterviewproject.interview_ayad`
-- ==============================================================================

WITH latest_catalog AS (
  -- Deduplicate to get the most recent snapshot of each SKU
  SELECT
    offer_id,
    title,
    brand,
    availability,
    condition,
    google_product_category,
    price.value AS regular_price,
    sale_price.value AS sale_price,
    COALESCE(
      NULLIF(sale_price.value, 0),
      NULLIF(price.value, 0)
    ) AS effective_price
  FROM (
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY offer_id 
        ORDER BY product_data_timestamp DESC
      ) AS rn
    FROM `quantacusinterviewproject.interview_ayad.Products`
  )
  WHERE rn = 1
)

SELECT
  COUNT(DISTINCT offer_id) AS total_catalog_skus,
  
  -- Availability Breakdown
  COUNTIF(LOWER(availability) = 'in stock') AS in_stock_skus,
  COUNTIF(LOWER(availability) = 'out of stock') AS out_of_stock_skus,
  COUNTIF(LOWER(availability) NOT IN ('in stock', 'out of stock') OR availability IS NULL) AS unknown_availability_skus,
  
  -- Pricing Diagnostics
  COUNTIF(effective_price IS NULL OR effective_price = 0) AS missing_price_skus,
  COUNTIF(sale_price > 0 AND sale_price < regular_price) AS active_discount_skus,
  
  -- Key Metadata Diagnostics
  COUNTIF(title IS NULL OR title = '') AS missing_title_skus,
  COUNTIF(brand IS NULL OR brand = '') AS missing_brand_skus,
  COUNTIF(google_product_category IS NULL) AS missing_category_skus,

  -- Portfolio Percentages
  ROUND(SAFE_DIVIDE(COUNTIF(LOWER(availability) = 'in stock'), COUNT(DISTINCT offer_id)) * 100, 2) AS in_stock_pct,
  ROUND(SAFE_DIVIDE(COUNTIF(sale_price > 0 AND sale_price < regular_price), COUNT(DISTINCT offer_id)) * 100, 2) AS discounted_pct
FROM latest_catalog;