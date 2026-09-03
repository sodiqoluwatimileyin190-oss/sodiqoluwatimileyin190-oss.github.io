# JRAD Superstores — Executive Retail Performance Dashboard


## Project Overview
A three-page executive Power BI dashboard analyzing a full year (Jan–Dec 2026) of
JRAD Superstores retail transaction data, covering revenue performance against
target, demand/time patterns, and customer segmentation. Built on a star-schema
data model with 16 custom Deneb (Vega-Lite) visuals — including a threshold-colored
gauge and a hand-built Sankey flow diagram — layered on top of native Power BI
visuals and 88 DAX measures.


---
## Business Questions Answered
- Are we on track to hit our monthly/annual revenue target, and by how much?
- Which branches and departments are over/under-performing, and by how much?
- How does revenue move throughout the year, and what drove the December peak
  and June dip?
- When does demand peak during the day/week, and how does spending shift across
  the salary cycle (Salary Week vs. Budget Week)?
- Which business events (Black Friday, Ramadan/Eid, Christmas, etc.) drove revenue
  above baseline, and by how much?
- Which customer personas drive the most value, and how do registered vs.
  walk-in customers compare?
- How does customer persona flow into shopping mission and department spend?

## Dashboard Pages

### 1. Executive Performance Overview
Revenue vs. target (gauge + variance), branch and department performance,
top-line KPIs (Total Revenue, Total Baskets, Average Basket Value, Target
Achievement), and headline business insights for the year.

### 2. Sales Performance & Time Intelligence
Demand cycles (peak day/hour), salary-cycle spending behavior, a waterfall
breakdown of business-event revenue uplift (+17.8% / ₦2.32bn above baseline),
and department revenue trends across the year.

### 3. Customer Segmentation
Persona-level value analysis (basket value vs. purchase frequency), a
Persona → Shopping Mission → Department Sankey flow, registered vs. walk-in
spend comparison, and salary-cycle sensitivity by persona.

## Key Findings
- December delivered ₦1.90bn — the strongest month of 2026 — capping a year led
  by the Christmas and Black Friday trading periods.
- June saw the sharpest monthly revenue decline (-12.7%) before recovering.
- Business events generated a combined ₦2.32bn uplift (+17.8%) above the normal
  trading baseline, led by Other Events, Black Friday, and the Festive Season.
- Demand peaks around 6 PM, concentrated in a 5–7 PM evening rush, with Saturday
  the highest-demand day of the week.
- Average basket value is strongest in Salary Week (~₦79K) and declines to ~₦56K
  by Budget Week.
- Premium and Family Shoppers show the strongest combined basket value and
  purchase frequency — the highest-value segment to prioritize.
- Weekly Grocery accounts for ~85% of shopping-mission revenue.
- Walk-in customers dominate the customer mix — a clear opportunity to convert
  frequent walk-ins into registered customers.
- Most individual branches fell short of their revenue targets, though total
  company revenue still met/exceeded the overall target.

## Technical Implementation
- **Data model:** Star schema — `FactSales` (plus `FactInventory`, `FactPayments`)
  surrounded by conformed dimensions (`DimDate`, `DimProduct`, `DimBranchBehaviour`,
  `DimCustomer`, `DimMonthlyBehaviour`, `Employee_Master`, `DimPricingHistory`),
  with a dedicated disconnected `_Measures` table holding all DAX.
- **DAX:** 88 measures in a dedicated disconnected `_Measures` table, spanning
  core KPIs, a repeatable growth-calculation pattern (base → previous-period →
  dual-mode KPI-growth % → display text → color), target/gauge allocation
  measures (including proportional branch-level target allocation), an
  event-uplift model that computes baseline daily revenue from non-event days
  to isolate true event impact, and context-aware natural-language insight
  measures that switch between single-selection and "auto-find the top/bottom
  performer" modes depending on filter state.
  
- **Custom visualization:** 16 Deneb (Vega-Lite) visuals, including a
  needle gauge with hand-coded threshold color zones, a fully custom
  Persona → Shopping Mission → Department Sankey diagram (manual node/ribbon
  geometry — no native Vega-Lite Sankey mark exists), a business-event
  waterfall chart, and reusable insight-text-splitter callouts — all with
  conditional color logic authored in Vega expressions.
  
- **Report UX:** cross-page slicers (Month, Branch, Department), a custom
  page navigator, and a full CSS/JS animation system on the portfolio case
  study page (entrance choreography, ambient glow, hover-lift, staggered
  reveal).

## Tools
Power BI Desktop · DAX (88 measures) · Deneb (Vega-Lite) custom visual · GitHub Pages · HTML/CSS/JavaScript

## Screenshots
_Add page screenshots/GIFs here — Overview, Sales & Time, Customer Segmentation._

## Business Impact
_Framed around the key findings above: e.g. "surfaced a ₦2.32bn uplift
opportunity tied to business events for inventory/staffing planning," "identified
an under-leveraged walk-in-to-registered conversion opportunity," "quantified
salary-cycle spending decline to inform promotion timing."_

