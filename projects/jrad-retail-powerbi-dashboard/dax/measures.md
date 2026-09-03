# DAX Measures

88 measures, organized in a dedicated disconnected `_Measures` table, referenced throughout the report as `_Measures.<name>`.

## Core KPI Measures

```dax
Total Revenue =
SUM(FactSales[Line_Total])

Total Quantity Sold =
SUM(FactSales[Quantity])

Total Line Items =
COUNTROWS(FactSales)

Total Receipts =
DISTINCTCOUNT(FactSales[Receipt_No])

Average Basket Value =
DIVIDE([Total Revenue], [Total Receipts], 0)

Average Items per Receipt =
DIVIDE([Total Quantity Sold], [Total Receipts], 0)

Average Line Value =
DIVIDE([Total Revenue], [Total Line Items], 0)

Revenue per Unit =
DIVIDE([Total Revenue], [Total Quantity Sold], 0)

Average Purchase Frequency =
DIVIDE([Total Receipts], [Total Customers], 0)

Total Customers =
[Registered Customers]
    + CALCULATE([Total Receipts], FactSales[Customer_Type] = "Walk-In")

Registered Customers =
CALCULATE(
    DISTINCTCOUNT(FactSales[Customer_ID]),
    FactSales[Customer_Type] = "Registered"
)

Average Customer Spend =
DIVIDE([Total Revenue], [Total Customers])

Registered Receipt % =
DIVIDE([Registered Receipts], [Total Receipts], 0)

Walk-In Receipt % =
DIVIDE([Walk-In Receipts], [Total Receipts], 0)
```

## Growth Calculations

```dax
Revenue KPI Growth % =
VAR SelectedMonths = COUNTROWS(VALUES(DimDate[Month Number]))
VAR LatestMonthNum = MAX(DimDate[Month Number])
VAR PriorMonthNum = LatestMonthNum - 1
VAR LatestRevenue =
    CALCULATE(
        [Total Revenue],
        REMOVEFILTERS(DimDate[Month Number]),
        DimDate[Month Number] = LatestMonthNum
    )
VAR PriorRevenue =
    CALCULATE(
        [Total Revenue],
        REMOVEFILTERS(DimDate[Month Number]),
        DimDate[Month Number] = PriorMonthNum
    )
RETURN
IF(
    SelectedMonths = 1,
    DIVIDE([Revenue MoM Growth], [Revenue Previous Month], 0),
    DIVIDE(LatestRevenue - PriorRevenue, PriorRevenue, 0)
)

Revenue Previous Month =
CALCULATE([Total Revenue], PREVIOUSMONTH(DimDate[Date]))

Revenue MoM Growth =
[Total Revenue] - [Revenue Previous Month]

Revenue MoM Growth % =
DIVIDE([Revenue MoM Growth], [Revenue Previous Month], 0)

Revenue Previous Day =
CALCULATE([Total Revenue], PREVIOUSDAY(DimDate[Date]))

Revenue Previous Year =
CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(DimDate[Date]))

Revenue YoY Growth % =
DIVIDE([Total Revenue] - [Revenue Previous Year], [Revenue Previous Year], 0)

Revenue YTD =
TOTALYTD([Total Revenue], DimDate[Date])

Basket Previous Month =
CALCULATE([Total Receipts], PREVIOUSMONTH(DimDate[Date]))

Basket MoM Growth =
[Total Receipts] - [Basket Previous Month]

Basket KPI Growth % =
VAR SelectedMonths = COUNTROWS(VALUES(DimDate[Month Number]))
VAR LatestMonthNum = MAX(DimDate[Month Number])
VAR PriorMonthNum = LatestMonthNum - 1
VAR LatestBaskets =
    CALCULATE(
        [Total Receipts],
        REMOVEFILTERS(DimDate[Month Number]),
        DimDate[Month Number] = LatestMonthNum
    )
VAR PriorBaskets =
    CALCULATE(
        [Total Receipts],
        REMOVEFILTERS(DimDate[Month Number]),
        DimDate[Month Number] = PriorMonthNum
    )
RETURN
IF(
    SelectedMonths = 1,
    DIVIDE([Basket MoM Growth], [Basket Previous Month], 0),
    DIVIDE(LatestBaskets - PriorBaskets, PriorBaskets, 0)
)

Average Basket Value Previous Month =
CALCULATE([Average Basket Value], PREVIOUSMONTH(DimDate[Date]))

Average Basket Value MoM Growth =
[Average Basket Value] - [Average Basket Value Previous Month]

Average Basket Value KPI Growth % =
VAR SelectedMonths = COUNTROWS(VALUES(DimDate[Month Number]))
VAR LatestMonthNum = MAX(DimDate[Month Number])
VAR PriorMonthNum = LatestMonthNum - 1
VAR LatestValue =
    CALCULATE(
        [Average Basket Value],
        REMOVEFILTERS(DimDate[Month Number]),
        DimDate[Month Number] = LatestMonthNum
    )
VAR PriorValue =
    CALCULATE(
        [Average Basket Value],
        REMOVEFILTERS(DimDate[Month Number]),
        DimDate[Month Number] = PriorMonthNum
    )
RETURN
IF(
    SelectedMonths = 1,
    DIVIDE([Average Basket Value MoM Growth], [Average Basket Value Previous Month], 0),
    DIVIDE(LatestValue - PriorValue, PriorValue, 0)
)

Average Customer Spend Previous Month =
CALCULATE([Average Customer Spend], DATEADD(DimDate[Date], -1, MONTH))

Average Customer Spend KPI Growth % =
VAR CurrentValue = [Average Customer Spend]
VAR PreviousValue = [Average Customer Spend Previous Month]
RETURN DIVIDE(CurrentValue - PreviousValue, PreviousValue)

Total Customers Previous Period =
CALCULATE([Total Customers], DATEADD(DimDate[Date], -1, MONTH))

Total Customer Activity Growth % =
VAR CurrentValue = [Total Customers]
VAR PreviousValue = [Total Customers Previous Period]
RETURN DIVIDE(CurrentValue - PreviousValue, PreviousValue)

Department Revenue Previous Period =
CALCULATE([Department Revenue], DATEADD(DimDate[Date], -1, MONTH))

Department Growth % =
DIVIDE(
    [Department Revenue] - [Department Revenue Previous Period],
    [Department Revenue Previous Period],
    0
)

Persona Revenue Previous Period =
CALCULATE([Total Revenue], DATEADD(DimDate[Date], -1, MONTH))

Persona Growth % =
DIVIDE(
    [Persona Revenue] - [Persona Revenue Previous Period],
    [Persona Revenue Previous Period],
    0
)
```

## Target / Gauge Measures

```dax
Monthly Revenue Target =
SUMX(
    VALUES(DimDate[Month Number]),
    VAR CurrentMonth = DimDate[Month Number]
    RETURN
        CALCULATE(
            SUM('Monthly Revenue Target'[Revenue Target]),
            'Monthly Revenue Target'[Month Number] = CurrentMonth
        )
)

Revenue Variance =
[Total Revenue] - [Monthly Revenue Target]

Target Achievement % =
DIVIDE([Total Revenue], [Monthly Revenue Target], 0)

Target Performance Status =
SWITCH(
    TRUE(),
    [Target Achievement %] >= 1.1, "Exceeding",
    [Target Achievement %] >= 0.9, "On Track",
    "Below Target"
)

Target Status =
VAR Achievement = [Target Achievement %]
RETURN
SWITCH(
    TRUE(),
    Achievement < 0.9, "Under Target",
    Achievement <= 1.1, "On Track",
    "Exceeding Target"
)

Target Variance % =
[Target Achievement %] - 1

Prior Month Achievement % =
CALCULATE([Target Achievement %], DATEADD(DimDate[Date], -1, MONTH))

Gauge Minimum = 0
Gauge Maximum = 1.5
Gauge Target = 1

Branch Target =
VAR TotalWeight =
    CALCULATE(SUM(DimBranchBehaviour[Branch Target Weight]), ALL(DimBranchBehaviour[Branch_Name]))
VAR CurrentBranchWeight = SUM(DimBranchBehaviour[Branch Target Weight])
RETURN [Monthly Revenue Target] * DIVIDE(CurrentBranchWeight, TotalWeight, 0)

Branch Target Variance % =
DIVIDE([Total Revenue] - [Branch Target], [Branch Target], 0)
```

## Time-Intelligence Measures

```dax
Peak Demand Hour =
VAR HourTable =
    ADDCOLUMNS(
        VALUES(FactSales[Transaction Hour]),
        "TransactionCount", CALCULATE(DISTINCTCOUNT(FactSales[Receipt_No]))
    )
VAR PeakHour =
    TOPN(1, HourTable, [TransactionCount], DESC, FactSales[Transaction Hour], ASC)
RETURN
    FORMAT(TIME(MAXX(PeakHour, FactSales[Transaction Hour]), 0, 0), "h AM/PM")

Peak Demand Day =
VAR DayTable =
    ADDCOLUMNS(
        ALLSELECTED(DimDate[Day Name], DimDate[Day of Week]),
        "ReceiptCount", CALCULATE(DISTINCTCOUNT(FactSales[Receipt_No]))
    )
VAR PeakDay = TOPN(1, DayTable, [ReceiptCount], DESC, DimDate[Day of Week], ASC)
RETURN MAXX(PeakDay, DimDate[Day Name])

Event Revenue Uplift =
VAR EventPeriods =
    ADDCOLUMNS(
        DimBusinessEvent,
        "EventRevenue",
            CALCULATE(
                [Total Revenue],
                DATESBETWEEN(DimDate[Date], DimBusinessEvent[Start_Date], DimBusinessEvent[End_Date])
            ),
        "EventDays", DATEDIFF(DimBusinessEvent[Start_Date], DimBusinessEvent[End_Date], DAY) + 1
    )
RETURN
    SUMX(
        EventPeriods,
        VAR EventRevenue = [EventRevenue]
        VAR EventDays = [EventDays]
        VAR StartDate = DimBusinessEvent[Start_Date]
        VAR EndDate = DimBusinessEvent[End_Date]
        VAR BaselineDailyRevenue =
            CALCULATE(
                DIVIDE([Total Revenue], COUNTROWS(DimDate)),
                REMOVEFILTERS(DimDate),
                DimDate[Date] < StartDate || DimDate[Date] > EndDate
            )
        VAR ExpectedRevenue = BaselineDailyRevenue * EventDays
        RETURN EventRevenue - ExpectedRevenue
    )

Event Revenue Uplift % =
VAR Uplift = [Event Revenue Uplift]
VAR EventPeriods =
    ADDCOLUMNS(
        DimBusinessEvent,
        "EventDays", DATEDIFF(DimBusinessEvent[Start_Date], DimBusinessEvent[End_Date], DAY) + 1
    )
VAR BaselineRevenue =
    SUMX(
        EventPeriods,
        VAR StartDate = DimBusinessEvent[Start_Date]
        VAR EndDate = DimBusinessEvent[End_Date]
        VAR EventDays = [EventDays]
        VAR BaselineDailyRevenue =
            CALCULATE(
                DIVIDE([Total Revenue], COUNTROWS(DimDate)),
                REMOVEFILTERS(DimDate),
                DimDate[Date] < StartDate || DimDate[Date] > EndDate
            )
        RETURN BaselineDailyRevenue * EventDays
    )
RETURN DIVIDE(Uplift, BaselineRevenue)

Normal Trading Baseline =
[Total Revenue] - [Event Revenue Uplift]

Event Revenue Trend =
VAR CurrentDate = MAX(DimDate[Date])
VAR IsEventDay =
    CALCULATE(
        COUNTROWS(DimBusinessEvent),
        FILTER(
            ALL(DimBusinessEvent),
            CurrentDate >= DimBusinessEvent[Start_Date] && CurrentDate <= DimBusinessEvent[End_Date]
        )
    )
RETURN IF(IsEventDay > 0, [Total Revenue], BLANK())

Event Uplift by Event =
VAR CurrentEvent = SELECTEDVALUE(DimBusinessEvent[Event_Name])
VAR StartDate = CALCULATE(MIN(DimBusinessEvent[Start_Date]), DimBusinessEvent[Event_Name] = CurrentEvent)
VAR EndDate = CALCULATE(MAX(DimBusinessEvent[End_Date]), DimBusinessEvent[Event_Name] = CurrentEvent)
VAR EventDays = DATEDIFF(StartDate, EndDate, DAY) + 1
VAR EventRevenue =
    CALCULATE([Total Revenue], DATESBETWEEN(DimDate[Date], StartDate, EndDate))
VAR RevenueOutsideEvent =
    CALCULATE(
        [Total Revenue],
        REMOVEFILTERS(DimDate),
        FILTER(ALL(DimDate[Date]), DimDate[Date] < StartDate || DimDate[Date] > EndDate)
    )
VAR DaysOutsideEvent =
    CALCULATE(
        COUNTROWS(DimDate),
        REMOVEFILTERS(DimDate),
        FILTER(ALL(DimDate[Date]), DimDate[Date] < StartDate || DimDate[Date] > EndDate)
    )
VAR BaselineDailyRevenue = DIVIDE(RevenueOutsideEvent, DaysOutsideEvent)
VAR ExpectedRevenue = BaselineDailyRevenue * EventDays
RETURN
    IF(NOT ISBLANK(CurrentEvent), EventRevenue - ExpectedRevenue)

Other Event Uplift =
VAR MajorEventUplift =
    SUMX(
        FILTER(
            ALL(DimBusinessEvent[Event_Name]),
            DimBusinessEvent[Event_Name] IN {
                "Eid Holiday", "Easter Weekend", "Black Friday", "Christmas Season"
            }
        ),
        CALCULATE([Event Uplift by Event])
    )
RETURN [Event Revenue Uplift] - MajorEventUplift

Waterfall Value =
VAR EventName = SELECTEDVALUE(WaterfallEvents[Waterfall_Event])
RETURN
SWITCH(
    EventName,
    "Normal Trading Baseline", [Normal Trading Baseline],
    "Ramadan / Eid", CALCULATE([Event Uplift by Event], DimBusinessEvent[Event_Name] = "Eid Holiday"),
    "Easter", CALCULATE([Event Uplift by Event], DimBusinessEvent[Event_Name] = "Easter Weekend"),
    "Other Events", [Other Event Uplift],
    "Black Friday", CALCULATE([Event Uplift by Event], DimBusinessEvent[Event_Name] = "Black Friday"),
    "Christmas / Festive Season", CALCULATE([Event Uplift by Event], DimBusinessEvent[Event_Name] = "Christmas Season"),
    "Actual Revenue", [Total Revenue],
    BLANK()
)
```

## Dynamic Insight-Text Measures

```dax
Insight - Branch Performance =
VAR SelectedBranch = SELECTEDVALUE(DimBranchBehaviour[Branch_Name])
VAR SelectedVariance = [Branch Target Variance %]
VAR TopBranch =
    TOPN(1, ALLSELECTED(DimBranchBehaviour[Branch_Name]), CALCULATE([Branch Target Variance %]), DESC)
VAR BottomBranch =
    TOPN(1, ALLSELECTED(DimBranchBehaviour[Branch_Name]), CALCULATE([Branch Target Variance %]), ASC)
VAR TopBranchName = MAXX(TopBranch, DimBranchBehaviour[Branch_Name])
VAR TopVariance = MAXX(TopBranch, CALCULATE([Branch Target Variance %]))
VAR BottomBranchName = MAXX(BottomBranch, DimBranchBehaviour[Branch_Name])
VAR BottomVariance = MAXX(BottomBranch, CALCULATE([Branch Target Variance %]))
RETURN
IF(
    HASONEVALUE(DimBranchBehaviour[Branch_Name]),
    SWITCH(
        TRUE(),
        SelectedVariance > 0,
            SelectedBranch & " is exceeding its revenue target by " & FORMAT(SelectedVariance, "0.0%"),
        SelectedVariance < 0,
            SelectedBranch & " is underperforming, falling below its revenue target by " & FORMAT(ABS(SelectedVariance), "0.0%"),
        SelectedBranch & " is currently meeting its revenue target."
    ),
    SWITCH(
        TRUE(),
        TopVariance > 0,
            TopBranchName & " is the strongest-performing branch, exceeding its revenue target by " & FORMAT(TopVariance, "0.0%"),
        BottomVariance < 0,
            BottomBranchName & " is the weakest-performing branch, falling below its revenue target by " & FORMAT(ABS(BottomVariance), "0.0%"),
        "All branches are currently meeting their revenue targets."
    )
)

Insight - Department Performance =
VAR TopDepartment =
    TOPN(
        1,
        ADDCOLUMNS(
            ALLSELECTED(DimProduct[Department]),
            "@Revenue", CALCULATE([Department Revenue]),
            "@Growth", CALCULATE([Department Growth %])
        ),
        [@Revenue], DESC
    )
VAR DepartmentName = MAXX(TopDepartment, DimProduct[Department])
VAR RevenueValue = MAXX(TopDepartment, [@Revenue])
VAR GrowthValue = MAXX(TopDepartment, [@Growth])
VAR RevenueText =
    IF(
        RevenueValue >= 1000000000,
        "₦" & FORMAT(RevenueValue / 1000000000, "0.00") & "bn",
        "₦" & FORMAT(RevenueValue / 1000000, "0.0") & "M"
    )
RETURN
    DepartmentName &
    " is the highest-revenue department," &
    " generating " & RevenueText &
    IF(
        GrowthValue > 0,
        " and growing by " & FORMAT(GrowthValue, "0.0%"),
        IF(
            GrowthValue < 0,
            " despite declining by " & FORMAT(ABS(GrowthValue), "0.0%"),
            " with no growth versus the prior period"
        )
    ) & "."

Insight - Customer Persona Performance =
VAR IsSinglePersona = HASONEVALUE(FactSales[Persona])
VAR PersonaPerformance =
    ADDCOLUMNS(
        ALLSELECTED(FactSales[Persona]),
        "@Contribution", CALCULATE([Persona Revenue %]),
        "@Growth", CALCULATE([Persona Growth %])
    )
VAR TopPersona = TOPN(1, PersonaPerformance, [@Contribution], DESC)
VAR PersonaName =
    IF(IsSinglePersona, SELECTEDVALUE(FactSales[Persona]), MAXX(TopPersona, FactSales[Persona]))
VAR ContributionValue =
    IF(IsSinglePersona, [Persona Revenue %], MAXX(TopPersona, [@Contribution]))
VAR GrowthValue =
    IF(IsSinglePersona, [Persona Growth %], MAXX(TopPersona, [@Growth]))
RETURN
    PersonaName &
    IF(IsSinglePersona, " is currently contributing ", " contributes ") &
    FORMAT(ContributionValue, "0.0%") &
    " of total," &
    IF(
        GrowthValue > 0,
        " revenue growing by " & FORMAT(GrowthValue, "0.0%") & " vs. the prior period.",
        IF(
            GrowthValue < 0,
            " while declining by " & FORMAT(ABS(GrowthValue), "0.0%") & " vs. the prior period.",
            " with no change vs. the prior period."
        )
    )

Revenue Performance Status =
VAR Growth = [Revenue MoM Growth]
RETURN SWITCH(TRUE(), Growth > 0, "Growth", Growth < 0, "Decline", "No Change")

Vs Target Label = "vs Target"

Measure = "vs Prior Month"
```

## Growth Display Measures

```dax
Revenue Growth Display =
VAR Growth = [Revenue KPI Growth %]
RETURN
IF(
    Growth >= 0,
    "⬆ " & FORMAT(Growth, "0.0%"),
    "⬇ " & FORMAT(ABS(Growth), "0.0%") & " vs Prior Month"
)

Revenue Growth Arrow =
IF([Revenue KPI Growth %] >= 0, "⬆", "⬇")

Basket Growth Display =
VAR Growth = [Basket KPI Growth %]
RETURN
IF(
    Growth >= 0,
    "⬆ " & FORMAT(Growth, "0.0%"),
    "⬇ " & FORMAT(ABS(Growth), "0.0%")
)

Average Basket Value Growth Display =
VAR Growth = [Average Basket Value KPI Growth %]
RETURN
IF(
    Growth >= 0,
    "⬆ " & FORMAT(Growth, "0.0%"),
    "⬇ " & FORMAT(ABS(Growth), "0.0%")
)

Average Customer Spend Growth Display =
VAR Growth = [Average Customer Spend KPI Growth %]
RETURN
    IF(
        ISBLANK(Growth),
        BLANK(),
        IF(
            Growth >= 0,
            "⬆ " & FORMAT(Growth, "0.0%"),
            "⬇ " & FORMAT(ABS(Growth), "0.0%")
        ))

Total Customer Activity Growth Display =
VAR Growth = [Total Customer Activity Growth %]
RETURN
    IF(
        ISBLANK(Growth),
        BLANK(),
        IF(
            Growth >= 0,
            "⬆ " & FORMAT(Growth, "0.0%"),
            "⬇ " & FORMAT(ABS(Growth), "0.0%")
        )
    )

Target Variance Display =
VAR TargetDiff = [Target Achievement %] - 1
RETURN
IF(
    TargetDiff >= 0,
    "⬆ " & FORMAT(TargetDiff, "0.0%"),
    "⬇ " & FORMAT(ABS(TargetDiff), "0.0%")
)

Event Revenue Uplift Display =
VAR UpliftPct = [Event Revenue Uplift %]
VAR Arrow = IF(UpliftPct >= 0, "⬆", "⬇")
RETURN Arrow & " " & FORMAT(ABS(UpliftPct), "0.0%")
```

## Conditional Formatting / Color Measures

```dax
Revenue Growth Color =
IF([Revenue KPI Growth %] >= 0, "#2E7D32", "#D32F2F")

Basket Growth Color =
IF([Basket KPI Growth %] >= 0, "#2E7D32", "#D32F2F")

Average Basket Value Growth Color =
IF([Average Basket Value KPI Growth %] >= 0, "#2E7D32", "#D32F2F")

Average Customer Spend Growth Color =
IF([Average Customer Spend KPI Growth %] >= 0, "#2E7D32", "#D32F2F")

Total Customer Activity Growth Color =
IF([Total Customer Activity Growth %] >= 0, "#2E7D32", "#D32F2F")

Target Variance Color =
VAR TargetDiff = [Target Achievement %] - 1
RETURN IF(TargetDiff >= 0, "#2E7D32", "#C62828")

Event Revenue Uplift Color =
IF([Event Revenue Uplift %] >= 0, "#2E8B57", "#E53935")
```

These measures are bound to card visuals via Format by Field Value, driving font color conditionally on growth/variance direction across the Overview, Sales & Time, and Customer Segmentation pages.

## Other Measures

```dax
Department Revenue = [Total Revenue]

Persona Revenue = [Total Revenue]

Persona Revenue % =
DIVIDE([Total Revenue], CALCULATE([Total Revenue], ALL(FactSales[Persona])), 0)

Persona Revenue Contribution % = [Persona Revenue %]

Registered Customer % =
DIVIDE([Registered Customers], [Total Customers], 0)

Registered Receipts =
CALCULATE([Total Receipts], FactSales[Customer_Type] = "Registered")

Walk-In Receipts =
CALCULATE([Total Receipts], FactSales[Customer_Type] = "Walk-In")

Walk-in Customers =
CALCULATE([Total Receipts], FactSales[Customer_Type] = "Walk-In")

Walk-in Customer % =
DIVIDE([Walk-in Customers], [Total Customers], 0)

Revenue Value M =
DIVIDE([Total Revenue], 1000000, 0)

Revenue MoM Positive =
IF([Revenue MoM Growth] > 0, [Total Revenue], BLANK())

Revenue MoM Negative =
IF([Revenue MoM Growth] < 0, [Total Revenue], BLANK())
```
