# AI Disclosure and Verification Log
## Quantacus Data and Strategy Case Study — BigQuery Jewellery Growth

**Candidate / Role:** Growth Analyst / Strategy Lead  
**Assessment:** Quantacus Case Study  
**Deliverable File:** `./quantacus_case_study/deliverables/ai_use_log.md`  
**Compliance Standard:** In strict accordance with Section 13 ("Rules for AI use") of the Quantacus Candidate Brief.

---

## 1. Overview & Policy Adherence

Quantacus explicitly encourages the thoughtful and transparent use of AI tools while maintaining 100% human accountability for all underlying SQL queries, data grains, mathematical models, and strategic recommendations. 

### Data Confidentiality Protection:
- **Zero Confidential Row-Level Data Export:** In compliance with Section 13, **no confidential, raw, row-level, or customer/brand identifiable data was exported, transmitted, or pasted into public AI models**.
- Only table schemas, grain definitions from the candidate brief, mathematical formulas, and anonymized aggregate structures were analyzed.

---

## 2. Inventory of Tools Used & Tasks Delegated

| Tool / Technology | Task Delegated | Scope of Human Review & Validation |
| :--- | :--- | :--- |
| **Google Antigravity Agentic Assistant** | Architecture structuring, implementation planning | Verified alignment with the brief's mandate of preserving commercial scale. |
| **Generative LLM (Gemini 3.8)** | SQL query drafting, BigQuery Standard SQL syntax optimization | Manually reviewed every Common Table Expression (CTE), join key, safe-cast, and window function. |
| **BigQuery Standard SQL Parser** | Syntax verification, schema validation | Tested against known BigQuery dialect rules (SAFE_DIVIDE, REGEXP_EXTRACT, QUALIFY). |
| **Markdown Documentation Framework** | Presentation slide structuring & speaker notes formatting | Refined commercial narrative, sensitivity models, and client Q&A talking points. |

---

## 3. Step-by-Step AI Delegation & Validation Record

### Task 1: Baseline Reconstruction & Attribution Lag Cutoff
- **AI Task Delegated:** Draft parameterized BigQuery Standard SQL to isolate the trailing conversion lag window.
- **AI Output Generated:** Initial draft used a static 7-day interval.
- **Human Verification & Rectification:** Increased lag exclusion window to 14 days based on jewellery ecommerce multi-touch consideration cycles. Enforced `DECLARE` statements at the top of `01_baseline_and_reconciliation.sql`. Confirmed that no micro-currency conversion was needed and verified date continuity.

### Task 2: Regex Price Parsing & Snapshot Deduplication
- **AI Task Delegated:** Construct safe parsing logic for `sale_price` and `price` fields containing irregular currency strings (e.g. `'19.99 USD'`) and deduplicate `list_obj`.
- **AI Output Generated:** Suggested `CAST(sale_price AS NUMERIC)`.
- **Human Verification & Rectification:** Caught potential runtime conversion error. Replaced with `SAFE_CAST(REGEXP_EXTRACT(sale_price, r'[\d.]+') AS NUMERIC)` and built the fallback logic: `COALESCE(NULLIF(sale_price, 0), NULLIF(price, 0))`. Validated snapshot deduplication using `QUALIFY ROW_NUMBER() OVER (PARTITION BY COALESCE(offer_id, sku_id) ORDER BY snapshot_date DESC) = 1`.

### Task 3: PMax Campaign vs. Product Item Grain Reconciliation
- **AI Task Delegated:** Write query reconciling `p_ads_Campaignbasicstats` against `Products`.
- **AI Output Generated:** Joined campaign table directly to products table.
- **Human Verification & Rectification:** Identified cartesian multiplication risk. Aggregated `Products` to the `campaign_id` level in an independent CTE *before* joining to `p_ads_Campaignbasicstats`. Confirmed that the resulting difference isolates non-product asset inventory spend.

### Task 4: Product Segmentation Matrix Logic
- **AI Task Delegated:** Propose segmentation rules for the 4 product decision groups.
- **AI Output Generated:** Suggested pausing all items with ROAS $< 2.0$ regardless of traffic.
- **Human Verification & Rectification:** Rejected this approach as violating the business brief's instructions on statistical sufficiency. Introduced a strict threshold ($\ge 40$ clicks and spend $> 2\times$ AOV) before designating an item as a Tier 3 bleeder, and created Tier 4 (Insufficient Evidence) to safeguard low-traffic items from false-negative pruning.

### Task 5: Financial Sensitivity & Presentation Narrative
- **AI Task Delegated:** Model the mathematical bridge from 3.4 to 5.0 ROAS and format 8 executive slides with a 15-minute presentation script.
- **AI Output Generated:** Provided a single point estimate of ROAS 5.0.
- **Human Verification & Rectification:** Expanded point estimate into a three-scenario sensitivity model (Conservative: 4.30, Base: 4.82, Optimistic: 5.20) incorporating realistic diminishing returns elasticity ($\epsilon = 0.85$) on reallocated media spend. Crafted a complete slide-by-slide speaker script with anticipated panel questions.

---

## 4. Live Panel Defense Readiness

I am prepared to live-explain and modify any query or assumption during the presentation and technical interview:
1. **Explain CTE Flow:** Walk through CTE mechanics in `01_` through `05_` and demonstrate how data grains are preserved.
2. **Live Query Alteration:** Modify threshold parameters (e.g., changing statistical click confidence from 40 to 60, or changing lag window from 14 to 21 days).
3. **Elasticity & Tradeoff Defense:** Justify why a linear budget reduction fails commercially and explain the mechanics of PMax non-product asset leakage.
