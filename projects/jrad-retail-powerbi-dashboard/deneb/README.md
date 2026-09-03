# Deneb / Vega-Lite

The report contains **16 custom Deneb visuals**.
# Deneb / Vega-Lite Custom Visuals

16 custom Deneb visuals built in Vega-Lite across the three report pages. Raw specs are in [`/specs`](./specs).

| # | Page | Type | Spec file | Description |
|---|---|---|---|---|
| 1 | Overview | Gauge | [`overview_01_target_gauge.json`](./specs/overview_01_target_gauge.json) | Semicircle dome gauge with needle and purple gradient banded zones (Under Target <95%, On Track 95–100%, Exceeding ≥100%), plus a KPI breakdown panel (Actual / Target / Variance) |
| 2 | Overview | Combo (area + line) | [`overview_02_revenue_trend.json`](./specs/overview_02_revenue_trend.json) | Revenue trend line/area with image layer and label |
| 3 | Overview | Bar (Branch) | [`overview_03_branch_performance_bars.json`](./specs/overview_03_branch_performance_bars.json) | Branch revenue bars, colored by `Branch Target Variance %` sign |
| 4 | Overview | Bar (Department) | [`overview_04_department_performance_bars.json`](./specs/overview_04_department_performance_bars.json) | Department revenue bars, colored by `Department Growth %` sign |
| 5 | Overview | Bar (Persona) | [`overview_05_persona_contribution_bars.json`](./specs/overview_05_persona_contribution_bars.json) | Persona revenue-contribution bars, colored by `Persona Growth %` sign |
| 6 | Overview | Insight callout | [`overview_06_insight_branch_performance.json`](./specs/overview_06_insight_branch_performance.json) | Splits `Insight - Branch Performance` text on first comma into headline + supporting line |
| 7 | Overview | Insight callout | [`overview_07_insight_department_performance.json`](./specs/overview_07_insight_department_performance.json) | Same pattern, for `Insight - Department Performance` |
| 8 | Overview | Insight callout | [`overview_08_insight_persona_performance.json`](./specs/overview_08_insight_persona_performance.json) | Same pattern, for `Insight - Customer Persona Performance` |
| 9 | Sales & Time | Rect band strip | [`sales_01_salary_cycle_band_strip.json`](./specs/sales_01_salary_cycle_band_strip.json) | Salary-cycle band strip (Salary Week → Budget Week) |
| 10 | Sales & Time | Waterfall chart | [`sales_02_event_uplift_waterfall.json`](./specs/sales_02_event_uplift_waterfall.json) | Bars ordered by fixed event sequence (Normal Trading Baseline → Ramadan/Eid → Easter → Other Events → Black Friday → Christmas/Festive → Actual Revenue), running total via `window` transform |
| 11 | Sales & Time | Trend line | [`sales_03_department_revenue_trend.json`](./specs/sales_03_department_revenue_trend.json) | Department revenue trend with highlighted December point |
| 12 | Sales & Time | Rect grid / dot plot | [`sales_04_basket_value_by_mission.json`](./specs/sales_04_basket_value_by_mission.json) | Small-multiples 3-column panel showing basket-value distribution by shopping mission |
| 13 | Customer Segmentation | Rect + text heatmap | [`customer_01_salary_cycle_by_persona.json`](./specs/customer_01_salary_cycle_by_persona.json) | Basket-value-by-persona-by-week grid |
| 14 | Customer Segmentation | Sankey flow diagram | [`customer_02_sankey_flow.json`](./specs/customer_02_sankey_flow.json) | Persona → Shopping Mission → Department flow, node size = revenue. Manual node positioning (`aggregate` → `window` row_number/cumsum → pixel-space y0 calculation) and manual ribbon geometry between three lookup-joined node tables |
| 15 | Customer Segmentation | Comparison dashboard | [`customer_03_registered_vs_walkin_comparison.json`](./specs/customer_03_registered_vs_walkin_comparison.json) | Registered vs. Walk-in comparison across 4 metrics (ABV, Frequency, Spend, Contribution pp), each with a difference indicator |
| 16 | Customer Segmentation | Dot plot / basket-value bands | [`customer_04_basket_value_bands.json`](./specs/customer_04_basket_value_bands.json) | Buckets receipts into ₦0–10K, ₦10–20K... bands by persona, with conditional label-color switching |

## Conditional Encoding

Gauge status color (visual 1):
```js
datum['Target Achievement %'] < 0.95 ? '#D64545'
  : (datum['Target Achievement %'] < 1.0 ? '#9F7AEA' : '#6F42C1')
```

Insight-text splitter, used in visuals 6, 7, 8:
```js
indexof(datum['Insight - Branch Performance'], ',')
// slice() the string into a headline + supporting line, rendered as two text marks
```

Green/red delta color, used in visuals 3, 4, 5, 15:
```js
[{ test: 'datum[<field>] > 0', value: '#15803D' },
 { test: 'datum[<field>] < 0', value: '#DC2626' }]
```

Currency label formatting, used across visuals 1, 2, 3, 4:
```js
'₦' + (v >= 1e9 ? format(v/1e9,'.2f')+'bn'
     : v >= 1e6 ? format(v/1e6,'.1f')+'M'
     : format(v,',.0f'))
```

Sankey node layout (visual 14):
```js
{ "type": "aggregate", "groupby": ["Department"], "fields": ["Line_Total"], "ops": ["sum"], "as": ["value"] },
{ "type": "collect", "sort": { "field": "value", "order": "descending" } },
{ "type": "window", "ops": ["row_number", "sum"], "fields": [null, "value"], "as": ["order", "cum"], "frame": [null, 0] },
{ "type": "formula", "as": "y0px", "expr": "yStart + (datum.order - 1) * (deptNodeHeight + nodePad...)" }
```
Followed by three `lookup` transforms joining Persona → Mission and Mission → Department node positions to draw the ribbons.
## Standout Visual
The Sankey is manually constructed because Vega-Lite does not provide a native Sankey mark. Node ordering, cumulative positions, lookups, and ribbon geometry are calculated in the specification.



