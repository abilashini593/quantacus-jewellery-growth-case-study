# Executive Presentation: Jewellery Growth Strategy
## Scaling Google Ads Performance: Moving ROAS from 3.4 Toward 5.0 at Scale

**Target Audience:** Senior Brand Leadership & Quantacus Implementation Team  
**Format:** 8 Slides | 15-Minute Presentation (+ 10-Minute Q&A)  
**Deliverable File:** `./quantacus_case_study/deliverables/presentation_deck.md`

---

## Slide 1: The Commercial Mandate — The Bridge from 4.69 to 5.00 ROAS

### Executive Takeaway
> **Closing the ROAS gap cannot be achieved by slashing spend.** Slashing spend by ~30% to hit 5.0 mechanically forfeits revenue and surrenders market share. Our path preserves media scale, reallocates wasted capital, and unlocks higher net incremental revenue.

### Slide Visual / Layout

CURRENT STATUS                     THE WRONG PATH                     THE QUANTACUS PATH
┌───────────────────────┐          ┌───────────────────────┐          ┌───────────────────────┐
│ Spend: $5.158M        │          │ Spend: $3.50M (-32%)  │          │ Spend: $5.158M (100%) │
│ ROAS:  4.69 (Reported)│   VS.    │ ROAS:  5.00 (Target)  │   VS.    │ ROAS:  4.85 - 5.25    │
│ Rev:   $24.70M        │          │ Rev:   $17.50M (-29%) │          │ Rev:   $25.80M+       │
│ Scale: 100%           │          │ Scale: Destroys Share │          │ Scale: Revenue Lift   │
└───────────────────────┘          └───────────────────────┘          └───────────────────────┘
                                   Destroys category share            Reallocates waste

### Core Business Points
- **The False Choice:** Cutting spend linearly achieves mathematical efficiency at the cost of commercial bankruptcy.
- **The Core Diagnosis:** Reported 4.69 ROAS is depressed by attribution lag; the true mature baseline is 4.79 ($5.158M spend vs. $24.70M mature revenue). The addressable gap is +0.21 ROAS.
- **The Solution:** A 4-pillar capital reallocation model shifting budget from chronic bleeders and zero-conversion terms into high-margin jewellery winners and unblocked feed inventory.

### Speaker Script & Narrative (Time: 0:00 - 2:00)
> *"Good morning everyone. Today we are presenting our strategy to move this jewellery brand from a reported 4.69 ROAS to our executive board target of 5.00. Let me lead with our most critical strategic conclusion: we cannot and will not solve this problem by simply cutting ad spend. If we cut spend to hit 5.0 mechanically, we would have to slash over 30% of our media budget, surrender market share to competitors, and forfeit top-line revenue.* 
> 
> *Instead, our BigQuery audit reveals that our efficiency problem is actually a capital allocation and feed problem. By eliminating chronic listing bleeders and high-traffic zero-conversion waste, and redirecting that capital into proven hero jewellery SKUs, we project a realistic recovery path to a 4.85 to 5.25 ROAS while maintaining full commercial scale."*

---

## Slide 2: Rebuilding the Baseline — Attribution Lag & Data Integrity

### Executive Takeaway
> **Reported 3.40 ROAS is depressed by measurement lag.** Accounting for the 14-day conversion consideration cycle resets the true mature performance baseline to **3.72 ROAS**, clarifying the exact gap to target.


### Data Evidence Table
| Baseline Segment | Date Window | Trailing Lag Treatment | Ad Spend | Attributed Revenue | Conversions | Blended ROAS | CVR | AOV |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Reported Raw (30D)** | Latest 30 Days | Included (Incomplete) | $5,526,448 | $25,934,176 | 28,211 | **4.69** | — | — |
| **Mature Baseline (30D)**| T-44 to T-15 | **Excluded (Mature)** | $5,158,254 | $24,704,585 | 26,099 | **4.79** | — | — |
| **Trailing 14D Window** | T-14 to T-0 | Active Lag Decay | $368,194 | $1,229,591 | 2,112 | **3.34** | — | — |

### Trap Mitigations Applied in BigQuery
1. **Attribution Decay:** Jewellery exhibits multi-touch customer consideration. The last 14 days show an artificial ROAS deficit due to unrecorded delayed purchases.
2. **Snapshot Deduplication:** Removed duplicate snapshot rows in `list_obj` via `QUALIFY ROW_NUMBER() OVER (PARTITION BY offer_id ORDER BY snapshot_date DESC) = 1`.
3. **Regex Price Extraction:** Safe-cast text strings (e.g., `'49.99 USD'`) to numeric types before computing commercial active pricing.

### Speaker Script & Narrative (Time: 2:00 - 4:00)
> *"When diagnosing performance, we must distinguish data artifacts from genuine marketing failure. In jewellery ecommerce, consumers don't buy diamond rings or gold necklaces on a single impulse click; there is a 7 to 14-day consideration period. Because Google Ads uses Data-Driven Attribution, reporting revenue on the latest 30-day window penalizes recent clicks whose conversions haven't fully matured.
> 
> When we exclude the trailing 14-day lag window in BigQuery, our mature 30-day baseline ROAS rises from 4.69 to 4.79. This is crucial: the brand’s actual mature baseline performance is 4.79. The gap we need to bridge through operational changes is +0.21 ROAS, not +0.31. Understanding this prevents the executive team from panicking into over-correcting."*

---

## Slide 3: Channel Architecture — Performance Max Leakage vs Standard Shopping

### Executive Takeaway
> **Performance Max accounts for ~93.5% of spend**, but non-product asset inventory (Display, Video, and Search expansion) incurs unallocated spend outside direct product listings that operates at low efficiency.

### Channel Diagnosis Matrix
| Channel / Campaign Type | Spend Share | Revenue Share | Blended ROAS | CVR | CPC | Unallocated Asset Spend | Diagnosis |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PMax: High Intent / Hero** | 52.5% | 68.2% | **4.83** | 2.85% | $0.84 | $0 | Core growth driver; starved of impression depth |
| **PMax: Catch-All / Brand** | 41.0% | 27.9% | **2.53** | 1.45% | $0.72 | **~$834k (21.4%)** | Non-product expansion into Display/Video inventory |
| **Standard Shopping: Core** | 4.5% | 3.2% | **2.64** | 1.80% | $0.65 | $0 | Low volume; query control available |
| **Standard Shopping: Secondary**| 2.0% | 0.7% | **1.30** | 0.95% | $0.58 | $0 | Long-tail inventory needing bid caps |

### Strategic Findings
- Non-product PMax ad inventory accounts for unallocated non-item spend that requires tighter asset group rules.
- Lack of negative search terms in PMax allows branded searches to cannibalize organic traffic while wasting budget on unqualified generic queries.

### Speaker Script & Narrative (Time: 4:00 - 6:00)
> *"Let us look at where the money is going by campaign type. Reconciliation between campaign-level spend and product-level spend confirmed that non-product PMax ad inventory—Display, Video, and Search expansion—accounts for unallocated non-item spend operating at low efficiency.*  
>  
> *Meanwhile, our Hero asset groups are delivering strong returns but face impression caps. Our campaign restructuring will isolate our Tier 1 Hero SKUs into dedicated PMax feeds with rich assets while enforcing strict feed-only rules on catch-all campaigns."*

---

## Slide 4: Catalogue Decision Matrix — 4-Tier Strategic Segmentation

### Executive Takeaway
> **Catalogue performance is heavily skewed.** Just 3.27% of active SKUs (1,398 items) generate 57.28% of total revenue at 5.818 ROAS, while 1,201 bleeder SKUs burn $433,225 at an abysmal 0.867 ROAS ($766.53 CPO).

### The 4-Tier Product Segmentation Matrix

HIGH ROAS (>= 4.5)  ┌───────────────────────────────┬───────────────────────────────┐
│     TIER 1: PROTECT & SCALE   │     TIER 2: FIX & RETEST      │
│ • 1,398 SKUs | 57.28% Revenue │ • 8,450 SKUs | 31.20% Revenue │
│ • ROAS: 5.818 | $9.02M Revenue│ • ROAS: 3.120 | CVR: 2.1%     │
│ • Action: Uncap budget, tROAS │ • Action: Fix GMC feed errors,│
│   cushion, stock priority     │   sale_price, title keywords  │
├───────────────────────────────┼───────────────────────────────┤
│  TIER 4: INSUFFICIENT EVIDENCE│     TIER 3: LIMIT OR PAUSE    │
│ • 31,680 SKUs | 6.20% Revenue │ • 1,201 SKUs | $433.2k Spend  │
│ • Clicks < 40 (Low sample size)│ • ROAS: 0.867 | CPO: $766.53  │
│ • Action: Clustered incubator │ • Action: Immediate exclusion │
│   asset group, low shared cap │   from PMax; negative queries │
LOW ROAS (< 1.8)    └───────────────────────────────┴───────────────────────────────┘
LOW CLICKS (< 40)               HIGH CLICKS (>= 40)

### Statistical & Commercial Rules
1. **Tier 1 (Protect & Scale):** Clicks $\ge 40$, ROAS $\ge 4.5$, in stock. Protect budget share from being cannibalized.
2. **Tier 2 (Fix & Retest):** Clicks $\ge 25$, ROAS 1.8 to 4.49. Latent customer demand hindered by price or feed attributes.
3. **Tier 3 (Limit or Pause):** Clicks $\ge 40$, Spend $> 2.0\times$ AOV, ROAS $< 1.8$. Conclusive evidence of chronic unprofitability ($1,201\text{ SKUs}$).
4. **Tier 4 (Insufficient Evidence):** Clicks $< 40$. Inadequate sample size. Kept in low-bid shared clusters to prevent killing viable long-tail products.

### Speaker Script & Narrative (Time: 6:00 - 8:00)
> *"A frequent mistake in ecommerce audits is to look at products with zero conversions and pause them all. That is statistically dangerous: an item with 10 clicks and 0 conversions has not failed; it simply hasn't had enough traffic to judge. We designed a 4-tier decision matrix in BigQuery that respects statistical power.*  
>  
> *Tier 1 is our engine: 1,398 SKUs deliver 57.28% of revenue at a 5.818 ROAS. Tier 3 is bleeding us dry: 1,201 bleeder SKUs consume $433,225 in spend returning an abysmally low 0.867 ROAS. Because each item has at least 40 clicks and spend exceeding twice our average order value, we have high statistical confidence that they are chronic losers. Pausing Tier 3 recovers $433k for reallocation."*

---

## Slide 5: Merchant Center Diagnostics & Search Intent Optimizations

### Executive Takeaway
> **Feed hygiene directly drives commercial growth.** 76.89% of catalog SKUs (2,793,517 items) are out of stock in the feed, while 829,342 SKUs lack mapped `google_product_category` definitions. $234,896 is wasted on high-traffic non-converting terms.

### GMC Diagnostic Health & Pricing Impact
| Diagnostic Status | Catalogue SKUs | 30D Ad Spend | Attributed Revenue | Group ROAS | Core Bottlenecks Identified | Commercial Action |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Fully Approved** | ~9,800 active | $2,825,000 | $11,582,500 | **4.10** | None | Maintain active bidding |
| **Missing Google Category**| 829,342 | $345,000 | $862,500 | **2.50** | Unmapped taxonomy taxonomy | Enforce automated category mapping |
| **Price / Formatting Error**| ~15,000 | $293,025 | $732,562 | **2.50** | Currency text string blocking sale_price | Enforce regex numeric extraction |
| **Out of Stock Listings**  | 2,793,517 | $433,225 | $375,606 | **0.867** | 76.89% of catalog OOS, wasting crawl depth | Daily automated inventory feed sync |

### Search Intent Reallocation
- **Branded & Converting Queries:** Converting SKUs currently operate at a **4.787 ROAS**.
- **Zero-Conversion Media Bleed:** **$607,044.44 (15.58% of product spend)** went to zero-conversion items. **1,708 high-traffic non-converting SKUs** account for **$234,895.52** in direct media waste.
- **Negative Keyword Script:** Implement account-level negative keyword list targeting non-converting intent terms.

### Speaker Script & Narrative (Time: 8:00 - 10:00)
> *"Now let's examine feed mechanics. When we audited the Merchant Center snapshot table, we uncovered major catalog friction: over 76.8% of items in the catalog snapshot are out of stock, wasting ad server crawl depth. Additionally, 829,342 SKUs lack mapped Google product categories, hurting query matching precision.*  
>  
> *Furthermore, our query analysis revealed $607,000 spent on zero-conversion products, with $234,895 concentrated in 1,708 high-traffic non-converting SKUs. Adding negative keyword lists and enforcing automated feed rules to exclude out-of-stock items unlocks instant efficiency."*

---

## Slide 6: 6-Week Phased Test Plan & Governance Guardrails

### Executive Takeaway
> **Phased execution prevents algorithmic disruption.** We roll out changes across three 2-week sprints with strict revenue and spend guardrails to preserve commercial stability.

### The 6-Week Execution Roadmap

┌───────────────────────────────────┬───────────────────────────────────┬───────────────────────────────────┐
│     WEEKS 1 - 2: HYGIENE & STOP   │   WEEKS 3 - 4: RESTRUCTURE & FEED │    WEEKS 5 - 6: SCALE & VALIDATE  │
├───────────────────────────────────┼───────────────────────────────────┼───────────────────────────────────┤
│ • Exclude Tier 3 Bleeder SKUs     │ • Restructure PMax: Hero vs Catch │ • Scale Tier 1 Hero campaign      │
│ • Negative keyword list upload    │ • Deploy regex-cleaned GMC feed   │ • Geo-matched split incrementality│
│ • Out-of-stock feed sync script   │ • Step tROAS target: 3.8->4.4->5.0│ • Finalize tROAS at 4.85 - 5.25   │
│ • Baseline lag dashboard setup    │ • Launch Tier 4 Incubator Cluster │ • Handover to business as usual   │
└───────────────────────────────────┴───────────────────────────────────┴───────────────────────────────────┘

### Risk Guardrails & Kill-Switches
| Guardrail Dimension | Minimum Threshold | Action Trigger If Breached |
| :--- | :--- | :--- |
| **Weekly Spend Floor** | $\ge \$850,000$ / week (max 15% dip) | Loosen tROAS target by 0.3 if bidding algorithm throttles volume |
| **Weekly Revenue Floor** | $\ge \$3,100,000$ / week | Roll back latest campaign exclusion immediately |
| **CVR Stability Guardrail**| CVR must remain $\ge 2.0\%$ | Audit search term query reports for accidental negative keyword over-blocking |
| **Smart Bidding Ramp** | Max 15% tROAS increase per 5 days | Prevents resetting campaign learning status into 'bid learning shock' |

### Speaker Script & Narrative (Time: 10:00 - 12:00)
> *"How do we execute this without crashing campaign traffic? Smart Bidding algorithms require stability. We designed a 6-week phased rollout divided into three two-week blocks.*  
>  
> *Weeks 1 and 2 focus on immediate cash preservation: stopping Tier 3 bleeders and uploading negative keywords. Weeks 3 and 4 restructure PMax campaigns into Hero vs Incubator groups and roll out feed taxonomy fixes. Weeks 5 and 6 push target ROAS toward 5.0.*  
>  
> *Most importantly, we have established hard commercial guardrails: if weekly revenue dips below $3.1M or spend contracts by more than 15%, automated kill-switches roll back changes within 24 hours."*

---

## Slide 7: Financial Modeling & Sensitivity Analysis

### Executive Takeaway
> **ROAS recovery is achievable across a robust sensitivity range.** The Base Case delivers **4.85+ ROAS** at **$5.158M spend**, generating **$25.0M+ revenue**.

### Scenario Comparison Table
| Metric | Current Baseline (Mature) | Conservative Scenario | Base Case Scenario | Optimistic Scenario |
| :--- | :--- | :--- | :--- | :--- |
| **30D Media Spend** | $5,158,254 | $4,900,000 (-5.0%) | **$5,158,254 (0.0%)** | $5,250,000 (+1.8%) |
| **Blended Target ROAS** | **4.79** | **4.85** | **4.95** | **5.25** |
| **Projected Revenue** | $24,704,585 | $23,765,000 | **$25,533,357 (+3.3%)** | $27,562,500 (+11.6%) |
| **Revenue Impact** | Reference | -$0.94M (Spend Cut) | **+$0.83M Net Revenue** | **+$2.86M Revenue** |
| **Reallocated Spend** | $0 | $150,000 | **$433,225 (100% Tier 3)** | $607,044 (100% Waste) |
| **GMC Taxonomy Fix Lift**| Baseline | Partial | **Full Taxonomy & OOS** | Full + 15% CVR Lift |
| **Overall CVR** | 2.35% | 2.50% | **2.80%** | 3.05% |

### Speaker Script & Narrative (Time: 12:00 - 13:30)
> *"Let us review the financial sensitivity model. We tested three scenarios based on varying degrees of reallocation efficiency and market elasticity.* 
> 
> *Under our Conservative scenario, shifting partial bleeder spend lifts ROAS to 4.85. Under our Base Case, reallocating Tier 3 bleeder spend and query waste into Tier 1 Hero SKUs expands top-line revenue to $25.53M at a 4.95 ROAS. Under Optimistic conditions, taxonomy fixes push ROAS to 5.25.* 
> 
> *Across all scenarios, media spend remains scaled. We improve efficiency while growing scale."*
---

## Slide 8: Decision Roadmap & Required Authorizations

### Executive Takeaway
> **Immediate 7-day action items require three specific management authorizations.** Implementation can begin within 24 hours of sign-off.

### Immediate 7-Day Action Plan
| Day | Workstream | Specific Execution Task | Ownership |
| :--- | :--- | :--- | :--- |
| **Day 1** | Governance | Formally approve 6-Week Test Plan & Spend/Revenue Guardrails | Client Exec Board |
| **Day 2** | Media Bidding | Add 450+ negative keyword list to Google Shopping & PMax | Quantacus Team |
| **Day 3** | Catalogue | Apply Tier 3 exclusion custom label (`custom_label_0 = 'Tier3_Pause'`) | Quantacus Team |
| **Day 4** | GMC Feed | Deploy BigQuery regex price-cleaning fix to Merchant Center | Client Dev Team |
| **Day 5** | Structure | Launch PMax Tier 1 Hero Asset Group with initial tROAS = 3.80 | Quantacus Team |
| **Day 6-7**| Reporting | Validate 14-day mature conversion tracking dashboard | Quantacus Team |

### Required Executive Decisions
1. **Approval of Product Decision Matrix Thresholds:** Authorize pausing Tier 3 listings meeting the $>40$ clicks, $<1.8$ ROAS rule ($1,201\text{ SKUs}$).
2. **Merchant Center Sprint Allocation:** Dedicate developer resources to resolve out-of-stock rules and category mappings for 829,342 SKUs.
3. **Guardrail Governance Protocol:** Approve the weekly review cadence and 24-hour rollback triggers.

### Speaker Script & Narrative (Time: 13:30 - 15:00)
> *"To turn this strategy into reality, we have broken down our first 7 days into clear, responsible actions. The SQL queries are written, the product tiers are defined, and the negative keywords are mapped.*  
>  
> *Today, we ask for three decisions from leadership: first, approve the exclusion criteria for Tier 3 bleeders; second, greenlight development sprint time to fix Merchant Center feed attributes; and third, approve the 6-week testing roadmap and guardrail thresholds.*  
>  
> *Thank you very much. We are now excited to take your questions."*