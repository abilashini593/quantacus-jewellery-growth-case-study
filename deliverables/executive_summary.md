# Executive Summary: Path to ROAS 5.0

**Client:** Jewellery Brand E-Commerce  
**Prepared by:** Quantacus Data & Strategy Practice  
**Decision Horizon:** Immediate Actions + 6-Week Phased Test Plan  
**Mandate:** Scale Google Shopping & PMax ROAS from reported 3.40 toward 5.0+ while preserving commercial scale and top-line revenue.

---

### 1. Executive Context & The Core Dilemma
The account reported a blended Google Ads ROAS of **3.40** over the latest 30-day window against an executive board target of **5.00**. Addressing this gap strictly by slashing media spend is commercially unviable: a linear spend reduction would require a **~30% spend contraction**, sacrificing upwards of $1.1M in quarterly top-line revenue, stranding inventory, and suppressing customer acquisition in high-margin jewellery categories.

Our BigQuery audit reveals that the reported 3.40 metric is **both distorted by conversion lag and weighed down by structural misallocations** across catalog availability, feed errors, and zero-conversion search intent.

---

### 2. Reconciled Baseline & Forensic Diagnosis

1. **Attribution Lag Correction:**  
   Jewellery purchases exhibit a 7-to-14 day decision window. Because Google Ads uses Data-Driven Attribution (DDA), trailing 14-day conversion values are incomplete. Rebuilding the baseline over a mature 30-day window (excluding the 14-day lag buffer) establishes the true baseline ROAS at **3.72** ($3,896,250.67 spend vs. $14,490,000 mature revenue). The true optimization gap to 5.00 is **+1.28 ROAS**, not +1.60.
2. **PMax Asset & Channel Leakage:**  
   Reconciliation between campaign-level spend (`p_ads_Campaignbasicstats`) and product-level spend (`Products`) confirmed that non-product PMax ad inventory (Display, Video, and Search expansion) accounts for unallocated non-item spend that requires tighter asset group rules.
3. **Catalog Capital Bipolarity:**  
   * **Tier 1 (Protect & Scale):** Just **1,398 SKUs (3.27% of active items)** generate **57.28% of total revenue** ($9,017,870.55) at a strong **5.818 ROAS**, but face impression caps.
   * **Tier 3 (Limit / Pause):** **1,201 bleeder SKUs** consume **$433,225.17 (11.12% of spend)** returning an abysmal **0.867 ROAS** ($766.53 Cost Per Order).
4. **Zero-Conversion Media Bleed:**  
   **$607,044.44 (15.58% of total product spend)** was expended on SKUs producing 0 conversions. Within this, **1,708 high-traffic non-converting SKUs** bleed **$234,895.52** in direct media waste. (Note: Converting SKUs currently operate at a **4.787 ROAS**).
5. **Merchant Center Inventory Friction:**  
   Catalog analysis revealed that **76.89% of catalog SKUs (2,793,517 items)** are out of stock, wasting ad server crawl depth. Additionally, **829,342 SKUs** lack mapped `google_product_category` definitions.

---

### 3. Financial Reallocation & Sensitivity Analysis

| Scenario | Strategic Assumptions | Reallocated Spend | Total Spend | Projected Revenue | Blended ROAS | Revenue Impact |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Current Baseline** | Mature 30D Window (Lag Exclusion) | $0 | $3,896,251 | $14,490,000 | **3.72** | Baseline |
| **Conservative** | Shift 15% Tier 3 spend to Tier 1; 50% waste eliminated | $150,000 | $3,700,000 | $17,945,000 | **4.85** | +$3.45M Revenue |
| **Base Case** | Reallocate 100% Tier 3 bleeder spend ($433k) & $234.9k waste into Tier 1/2 | $433,225 | $3,896,251 | $18,780,000 | **4.82** | **+$4.29M Net Revenue** |
| **Optimistic** | Full waste recovery ($607k) + GMC taxonomy fixes lift CVR by 15% | $607,044 | $3,950,000 | $20,737,500 | **5.25** | +$6.25M Revenue |

*Conclusion:* The **Base Case** delivers a **4.82 ROAS** while preserving full media scale, bridging the gap to **5.0+** in the Optimistic scenario without cutting core customer acquisition spend.

---

### 4. Prioritized 4-Pillar Action Plan
┌───────────────────────────┬───────────────────────────┐
│ 1. Product Selection      │ 2. GMC Feed Remediation   │
│ • Scale Tier 1 (ROAS >4.5)│ • Exclude OOS listings    │
│ • Reallocate $433k Tier 3 │ • Map 829k missing cats   │
│ • Eliminate $234k waste   │ • Clean price formatting  │
├───────────────────────────┼───────────────────────────┤
│ 3. PMax Architecture      │ 4. Calibrated Bidding     │
│ • Isolate Hero PMax feed  │ • Enforce 14D lag window  │
│ • Catch-all feed-only     │ • Step tROAS: 3.8->4.4->5.0│
│ • Prune negative search   │ • Weekly guardrail checks │
└───────────────────────────┴───────────────────────────┘
1. **Product Rationalization & Reallocation:**  
   Immediately exclude/pause confirmed Tier 3 bleeder SKUs ($433.2k spend) and 1,708 zero-conversion terms ($234.9k waste). Reallocate recovered budget directly into Tier 1 Hero SKUs.
2. **Merchant Center Feed Unlocking:**  
   Apply daily feed rules to exclude out-of-stock items (76.89% of catalog). Map `google_product_category` taxonomies for 829,342 unmapped SKUs to improve query matching.
3. **PMax & Query Architecture:**  
   Segment Performance Max into a tiered setup: (A) *Hero Asset Group* (Tier 1 SKUs only, rich video/lifestyle assets, optimized tROAS); (B) *Catalog Incubator* (strict feed-only asset groups without display expansion); apply account-level negative search terms.
4. **Calibrated Bid Management:**  
   Avoid algorithmic shock by stepping target ROAS progressively: **3.80 in Week 1**, **4.40 in Week 3**, and **4.85–5.25 by Week 6** (limiting bid target shifts to $\le 15\%$ per cycle).

---

### 5. Governance, Operational Risks & Sign-Offs

* **Key Operational Risks:**  
  * *Algorithmic Re-learning:* Aggressive bid target shifts reset Smart Bidding models. *Mitigation:* Cap bid shifts to $\le 15\%$ per 5-day cycle.  
  * *Stock Depletion:* Concentrating spend on Tier 1 hero SKUs risks stock-outs. *Mitigation:* Automated feed alerts to pause ad serving when stock drops below 10 units.
* **Immediate Executive Decisions Required:**  
  1. Authorize pausing/capping 1,201 Tier 3 bleeder SKUs and 1,708 zero-conversion search terms.  
  2. Approve feed optimization sprint with dev team to resolve OOS rules and category mapping.  
  3. Sign off on the 6-Week Phased Testing Roadmap with weekly revenue and ROAS guardrails.