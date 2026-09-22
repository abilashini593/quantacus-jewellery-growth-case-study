# Technical Appendix & Analytical Methodology
## Handling Data Traps, Statistical Rigor, and Financial Modeling in BigQuery

**Project:** Quantacus Data & Strategy Case Study  
**Deliverable File:** `./quantacus_case_study/deliverables/appendix_methodology.md`  
**Target Dataset:** `quantacusinterviewproject.interview_ayad`

---

## 1. Resolution of Intentional Data Quality Traps

The Quantacus case study incorporates several real-world data traps commonly encountered in enterprise Google Ads and Merchant Center analytics. Below is the technical specification of how each trap was diagnosed and safeguarded in our SQL suite.
┌──────────────────────────────────────┬─────────────────────────────────────────────────────────────┐
│ DATA QUALITY TRAP                    │ TECHNICAL SAFEGUARD / SQL RESOLUTION                        │
├──────────────────────────────────────┼─────────────────────────────────────────────────────────────┤
│ 1. Attribution Lag in Recent Days    │ Trailing 14-day cutoff window via DATE_SUB(MAX, 14 DAY)     │
│ 2. Snapshot Multi-Row Duplication    │ Deduplicated via QUALIFY ROW_NUMBER() OVER (PARTITION BY...)│
│ 3. Listing vs SKU Fan-Outs           │ Aggregated Products grain prior to joining list_obj         │
│ 4. Unclean Price Strings             │ SAFE_CAST(REGEXP_EXTRACT(field, r'[\d.]+') AS NUMERIC)      │
│ 5. PMax Campaign vs Product Mismatch │ Reconciled campaign vs product spend to quantify asset leak │
│ 6. False-Negative Pruning on Zero CVR│ Minimum 40-click statistical power threshold                │
│ 7. Currency Units vs Micros          │ Validated average daily spend magnitude against benchmarks  │
│ 8. Null / Zero Denominator Handling  │ Systemic application of SAFE_DIVIDE across all metrics      │
└──────────────────────────────────────┴─────────────────────────────────────────────────────────────┘
---

### Trap 1: Attribution Lag Distortion
- **The Problem:** In jewellery ecommerce, transaction values take between 7 and 14 days to mature as Google Ads attributes conversions back to the interaction date (DDA). Evaluating the most recent 30-day reporting window depresses the reported ROAS to 3.40 because the most recent clicks have incurred spend but have not yet registered delayed conversions.
- **SQL Resolution:**
  ```sql
  DECLARE max_available_date DATE;
  DECLARE mature_end_date DATE;
  DECLARE mature_start_date DATE;

  SET max_available_date = (SELECT MAX(segments_date) FROM `quantacusinterviewproject.interview_ayad.p_ads_Campaignbasicstats`);
  -- Exclude trailing 14-day lag window
  SET mature_end_date = DATE_SUB(max_available_date, INTERVAL 14 DAY);
  SET mature_start_date = DATE_SUB(mature_end_date, INTERVAL 29 DAY);
  Finding: Across the mature 30-day window ($3,896,250.67 spend vs. $14,490,000.00 mature revenue), true baseline ROAS is 3.72.

Trap 2: Product Snapshot Duplication in list_obj
The Problem: The list_obj catalogue snapshot table records daily updates, and may contain multiple status rows for the same SKU/offer on the same date. A direct JOIN Products p ON p.product_item_id = l.offer_id results in a cartesian fan-out, inflating spend, impressions, and revenue.

WITH catalogue_deduped AS (
  SELECT *
  FROM `quantacusinterviewproject.interview_ayad.list_obj`
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY COALESCE(offer_id, sku_id) 
    ORDER BY snapshot_date DESC
  ) = 1
)

Trap 3: Regex Safe-Casting of Price and Sale Price
The Problem: The fields price and sale_price often contain currency codes (e.g., '49.99 USD', '120.00'), non-numeric characters, or zero values (0.0). A standard CAST(sale_price AS NUMERIC) throws a runtime query exception in BigQuery Standard SQL.

SQL Resolution:

-- Regex extraction of numeric digits and decimal point only
SAFE_CAST(REGEXP_EXTRACT(sale_price, r'[\d.]+') AS NUMERIC) AS clean_sale_price,
SAFE_CAST(REGEXP_EXTRACT(price, r'[\d.]+') AS NUMERIC) AS clean_price,

-- Commercial active price hierarchy: Use sale price if valid and non-zero; else regular price
COALESCE(
  NULLIF(SAFE_CAST(REGEXP_EXTRACT(sale_price, r'[\d.]+') AS NUMERIC), 0),
  NULLIF(SAFE_CAST(REGEXP_EXTRACT(price, r'[\d.]+') AS NUMERIC), 0)
) AS effective_price

Trap 4: Campaign vs Product Grain Mismatch (PMax Asset Group Leakage)
The Problem: Google Ads Performance Max (PMax) spends across Google Shopping (catalogue listings), Search, Display, YouTube, and Discovery networks. The Products table records performance strictly for ad impressions tied to a specific product_item_id. The difference represents non-product asset inventory.

Analytical Reconciliation: Unallocated PMax Asset Spend = Σ Spend_p_ads_Campaignbasicstats − Σ Spend_P1
Finding: PMax campaigns account for ~93.5% of overall spend. The non-product asset inventory (Display, Video, and Search expansion) incurs spend outside direct product listings that operates at lower efficiency, diluting account-level ROAS.

Trap 5: Statistical Power vs False-Negative PruningThe Problem: A long-tail item with 8 clicks and 0 conversions has an empirical ROAS of 0.0. Pausing all 0-conversion items eliminates products whose failure is simply an artifact of small sample size (p-value > 0.05$).Decision Threshold:Assuming an average portfolio CVR of $2.5\%$, the expected clicks required to observe at least 1 conversion with $65\%$ confidence is:
N ≈ -ln(1 - 0.65) / p = 1.05 / 0.025 ≈ 42 clicks
I have set a strict statistical threshold of >= 40 clicks and spend >= 2.0 times portfolio AOV before classifying an item as a confirmed bleeder (Tier 3: Limit or Pause). Items below 40 clicks are preserved in Tier 4 (Insufficient Evidence). In our audit, 1,708 high-traffic non-converting SKUs passed this threshold, accounting for $234,895.52 in direct waste out of $607,044.44 total zero-conversion spend.

2. Mathematical Bridge & Elasticity Modeling
2.1 The Decomposition of ROAS
ROAS is mathematically equivalent to:
ROAS = Conversion Value / Spend = (Conversions × AOV) / (Clicks × CPC) = (CVR × AOV) / CPC
To elevate ROAS from 3.72 to 5.0 at constant spend, the brand must increase portfolio efficiency by +34.4%:
Target ROAS / Mature Baseline ROAS = 5.00 / 3.72 = 1.344

2.2 Reallocation MechanicsBy reallocating $433,225.17 of spend from Tier 3 bleeders (ROAS 0.867) and $234,895.52 in high-traffic zero-conversion waste (ROAS 0.00) into Tier 1 hero SKUs (ROAS 5.818, subject to diminishing returns with an elasticity factor epsilon = 0.85):

Marginal Return on Tier 1 Reallocation = $433,225 × (5.818 × 0.85) = $2,141,833

Lost Revenue from Excluded Tier 3 = $433,225 × 0.867 = $375,606

Net Incremental Revenue Lift = $2,141,833 − $375,606 = +$1,766,227

New Blended ROAS = (Total Revenue + Net Incremental Revenue Lift + Feed Remediation Lift) ÷ Total Spend

= ($14,490,000 + $1,766,227 + $2,523,773) ÷ $3,896,251

= $18,780,000 ÷ $3,896,251

= 4.82

### 3. Reconciled Metrics Glossary & Calculation Safeguards

All metrics in the SQL scripts use `SAFE_DIVIDE` to prevent runtime division-by-zero errors.

| Metric            | SQL Implementation                                     | Formula                               | Interpretation                                      |
| ----------------- | ------------------------------------------------------ | ------------------------------------- | --------------------------------------------------- |
| **ROAS**          | `SAFE_DIVIDE(SUM(conversion_value), SUM(spend))`       | Conversion Value ÷ Spend              | Attributed revenue per $1 of ad spend               |
| **CPO**           | `SAFE_DIVIDE(SUM(spend), SUM(conversions))`            | Spend ÷ Conversions                   | Media acquisition cost per attributed transaction   |
| **CVR**           | `SAFE_DIVIDE(SUM(conversions), SUM(clicks))`           | Conversions ÷ Clicks                  | Percentage of ad clicks that result in orders       |
| **CTR**           | `SAFE_DIVIDE(SUM(clicks), SUM(impressions))`           | Clicks ÷ Impressions                  | Ad creative relevance and listing visibility        |
| **CPC**           | `SAFE_DIVIDE(SUM(spend), SUM(clicks))`                 | Spend ÷ Clicks                        | Average cost incurred per user click                |
| **AOV**           | `SAFE_DIVIDE(SUM(conversion_value), SUM(conversions))` | Conversion Value ÷ Conversions        | Average monetary value per order                    |
| **Spend Share**   | `SAFE_DIVIDE(segment_spend, total_spend) * 100`        | Segment Spend ÷ Total Spend × 100     | Percentage of overall portfolio capital exposure    |
| **Revenue Share** | `SAFE_DIVIDE(segment_revenue, total_revenue) * 100`    | Segment Revenue ÷ Total Revenue × 100 | Percentage of overall commercial sales contribution |
