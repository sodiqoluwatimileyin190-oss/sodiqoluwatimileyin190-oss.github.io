# Deneb / Vega-Lite

The report contains **16 custom Deneb visuals**.

## Highlighted Work
- Threshold-based needle gauge
- Revenue trend
- Branch performance
- Department performance
- Dynamic insight callouts
- Business-event waterfall
- Persona → Shopping Mission → Department Sankey
- Basket-value segmentation
- Registered vs Walk-In comparison

## Standout Visual
The Sankey is manually constructed because Vega-Lite does not provide a native Sankey mark. Node ordering, cumulative positions, lookups, and ribbon geometry are calculated in the specification.

## Conditional Encoding
Positive/negative states are authored directly through Vega-Lite expressions rather than native Power BI `FillRule` conditional formatting.

Place verified JSON specifications in this folder using descriptive filenames such as:

```text
01-executive-gauge.json
02-revenue-trend.json
03-branch-insight.json
04-branch-performance.json
...
14-persona-mission-department-sankey.json
...
16-registered-walkin-comparison.json
```
