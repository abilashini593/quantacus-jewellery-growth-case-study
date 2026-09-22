# 6-Week Test, Monitoring, and Experimentation Plan
## Moving Jewellery Google Ads ROAS from 3.4 toward 5.0 at Scale

**Project:** Quantacus Data and Strategy Case Study  
**Deliverable File:** `./quantacus_case_study/deliverables/test_and_monitoring_plan.md`  
**Execution Horizon:** 6 Weeks (3 x 14-Day Sprints)  

---

## 1. Experimental Philosophy & Incrementality Design

### 1.1 The Correlation vs. Incrementality Trap
In ecommerce advertising, reporting attribution (such as Google Ads DDA) measures **correlation, not causation**. A high reported ROAS in branded search or high-intent PMax shopping can often reflect orders that existing loyal customers would have placed organically without clicking an ad. Conversely, prospecting shopping traffic drives crucial top-of-funnel customer acquisition that paid search attribution systematically undervalues.

### 1.2 Comparison Methods
To validate whether our changes deliver genuine commercial recovery rather than seasonal or tracking anomalies, we implement a multi-layered testing structure:

| Test Scope | Method | Test Structure | Pros / Cons | Incrementality Isolation |
| :--- | :--- | :--- | :--- | :--- |
| **PMax Restructuring & Hero Asset Groups** | **Campaign Draft & Experiment (Split)** | 50/50 Traffic split on core Shopping inventory | Fast setup; isolates bidding & asset changes | High for ad-engine mechanics; moderate for brand cannibalization |
| **Search Negative & Bleeder Exclusions** | **Geo-Matched Market Test** | Region A (Treatment) vs Region B (Synthetic Control) | Completely isolates organic cannibalization | Highest gold-standard incrementality |
| **Feed Hygiene & Sale Price Formatting** | **Pre/Post with Baseline Covariate Control** | Compare SKU performance pre/post feed update, normalized by catalogue category trends | Pragmatic for Merchant Center approvals | Moderate; requires adjusting for seasonal trend |

---

## 2. Success Metrics & Hierarchy of Evidence

We establish a 3-tier metric hierarchy to balance efficiency with commercial revenue scale:

```
                  ┌─────────────────────────────────────────┐
                  │          PRIMARY NORTH-STAR             │
                  │   Blended Mature ROAS (Target: 4.8-5.2) │
                  │   Gross Ad Revenue (Target: >= £400k)   │
                  └────────────────────┬────────────────────┘
                                       │
                  ┌────────────────────▼────────────────────┐
                  │         SECONDARY EFFICIENCY            │
                  │   Conversion Rate (CVR >= 2.6%)         │
                  │   Cost per Order (CPO <= £28.00)        │
                  │   Asset Leakage Rate (<= 8% of PMax)    │
                  └────────────────────┬────────────────────┘
                                       │
                  ┌────────────────────▼────────────────────┐
                  │       OPERATIONAL & FEED HEALTH         │
                  │   GMC Disapproval Rate (< 1.5%)         │
                  │   Out-of-Stock Ad Spend (= £0)          │
                  │   Tier 1 Impression Share (>= 75%)      │
                  └─────────────────────────────────────────┘
```

---

## 3. Commercial Guardrails & Automated Kill-Switches

To adhere to the core business constraint—**preserving useful scale and revenue without reckless spend cutting**—we define hard guardrails:

| Guardrail Dimension | Safety Floor | Rationale | Immediate Remediation If Breached |
| :--- | :--- | :--- | :--- |
| **Weekly Spend Floor** | $\ge £20,000$ / week (Max -15% variance from baseline) | Prevents Smart Bidding from choking delivery due to sudden tROAS escalation | Loosen campaign target ROAS by 0.25 within 24 hours |
| **Weekly Revenue Floor** | $\ge £75,000$ / week (Trailing 7-day revenue) | Guarantees business cash flow and prevents inventory stranding | Re-activate borderline Tier 3 items into Tier 2 Fix & Retest |
| **Conversion Volume Floor** | $\ge 600$ orders / week | Sustains statistical machine learning density in Google's bidding algorithm | Broaden PMax audience signals with high-intent customer match lists |
| **Attribution Lag Buffer** | Exclude the most recent 14 days from performance evaluation | Avoids panicking over artificially incomplete recent conversion data | Enforce 14-day reporting lockout in executive review dashboards |

---

## 4. Phased 6-Week Execution Roadmap

```
SPRINT 1 (WEEKS 1 - 2)          SPRINT 2 (WEEKS 3 - 4)          SPRINT 3 (WEEKS 5 - 6)
HYGIENE & STOP THE BLEED        RESTRUCTURE & FEED UNLOCK       SCALE & INCREMENTALITY
┌──────────────────────┐        ┌──────────────────────┐        ┌──────────────────────┐
│• Exclude Tier 3 SKUs │        │• Restructure PMax    │        │• Step tROAS to 5.0   │
│• Upload 450+ Negatives│  ───>  │  Hero vs Incubator   │  ───>  │• Geo incrementality  │
│• Out-of-Stock sync   │        │• Regex price fixes   │        │  validation          │
│• Set tROAS to 3.8    │        │• Step tROAS to 4.4   │        │• Transition to BAU   │
└──────────────────────┘        └──────────────────────┘        └──────────────────────┘
```

### Sprint 1 (Weeks 1 – 2): Hygiene & Stop the Bleed
- **Objectives:** Immediately stop cash burn without algorithmic shock; eliminate unqualified generic search queries.
- **Specific Tasks:**
  1. Apply custom label `custom_label_0 = 'Tier3_Pause'` to 22% of SKUs flagged by `03_product_segmentation_matrix.sql`.
  2. Implement negative keyword list of 450+ non-converting intent terms (e.g. wholesale, repair, fake, cheap) across all Shopping campaigns.
  3. Deploy automated script checking `list_obj.availability` to pause zero-stock listings instantly.
  4. Adjust campaign target ROAS conservatively from 3.4 to **3.8** (preventing volume shock).
     Each tROAS change will be held for at least one full conversion cycle before the next adjustment, allowing Smart Bidding sufficient time to stabilize and absorb the change.
- **Gate Review 1 (End of Week 2):** Verify spend has not contracted by $>10\%$; confirm zero-conversion bleeder spend drops by $>80\%$.

### Sprint 2 (Weeks 3 – 4): Structural Realignment & Feed Unlocking
- **Objectives:** Direct capital to high-margin hero SKUs; resolve GMC disapprovals.
- **Specific Tasks:**
  1. Deploy PMax campaign restructuring:
     - **PMax Hero:** Tier 1 SKUs only; dedicated creative assets; tROAS = 4.2.
     - **PMax Catch-All:** Feed-only (no display/video expansion), tROAS = 4.8.
     - **Tier 4 Incubator:** Low shared budget (£50/day cap) to safely explore long-tail SKUs.
  2. Apply GMC regex price parsing script: clean sale price formatting and re-submit 215 disapproved listings.
  3. Step primary campaign tROAS from 3.8 to **4.4**.
- **Gate Review 2 (End of Week 4):** Verify unallocated PMax asset spend drops below 10%; confirm GMC disapproval rate drops under 2%.

### Sprint 3 (Weeks 5 – 6): Scaling Winners & Testing Incrementality
- **Objectives:** Push blended ROAS into the 4.8 – 5.2 target zone; measure true incrementality.
- **Specific Tasks:**
  1. Increase budget caps on Tier 1 Hero campaigns by 20% to capture available impression share.
  2. Conduct a matched-market geo test with a minimum 14-day observation window, extended if statistical power is insufficient   (Northern vs Southern territory split), testing a 10% bid increase on Tier 1 SKUs to establish true incremental ROAS (iROAS).
  3. Step target ROAS to final steady-state of **4.8 to 5.0**.
  4. Standardize automated weekly reporting dashboards with mature attribution lag exclusions.
- **Final Handover Review (End of Week 6):** Deliver post-test performance reconciliation report against baseline.

---

## 5. Decision Rules: Stop, Iterate, or Scale

```
                                 [WEEKLY PERFORMANCE REVIEW]
                                              │
                    ┌─────────────────────────┴─────────────────────────┐
                    ▼                                                   ▼
            [GUARDRAIL BREACHED?]                               [GUARDRAIL INTACT]
                    │                                                   │
         ┌──────────┴──────────┐                             ┌──────────┴──────────┐
         ▼                     ▼                             ▼                     ▼
[Spend dip > 15%]     [Weekly Revenue < £75k]           [ROAS >= Milestone]   [ROAS < Milestone]
  Loosen tROAS by 0.3    Revert exclusions;            Step tROAS up +0.3;   Audit search terms;
  Check search volume    Audit GMC feed errors         Expand Hero budget    Hold bids 7 days
```

1. **Scale Conditions:** If trailing 14-day mature ROAS exceeds milestone target (e.g. $>4.0$ in Week 2, $>4.5$ in Week 4) and spend remains $\ge £22k$/week, increase Tier 1 budget by 15%.
2. **Iterate Conditions:** If ROAS is flat ($3.7 - 3.9$) but spend and revenue are stable, hold bid targets for 7 additional days to allow Smart Bidding algorithms to absorb feed changes before adjusting further.
3. **Stop / Rollback Conditions:** If trailing 7-day revenue falls below £75,000 for two consecutive monitoring checkpoints, immediately initiate rollback of recent SKU exclusions and reset tROAS to the previous stable baseline.
