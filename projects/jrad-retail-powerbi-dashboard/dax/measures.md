# JRAD Power BI — DAX Measures

## Executive Performance

### Total Revenue

```DAX
Total Revenue =
SUM(FactSales[Line_Total])


Revenue Previous Month =
CALCULATE(
    [Total Revenue],
    DATEADD(DimDate[Date], -1, MONTH)
)


Revenue Growth % =
DIVIDE(
    [Total Revenue] - [Revenue Previous Month],
    [Revenue Previous Month],
    0
)

Department Revenue =
[Total Revenue]


Department Revenue Previous Period =
[Revenue Previous Month]


Department Growth % =
DIVIDE(
    [Department Revenue] - [Department Revenue Previous Period],
    [Department Revenue Previous Period],
    0
)

Persona Revenue =
[Total Revenue]

Persona Revenue Previous Period =
[Revenue Previous Month]

Persona Revenue Contribution % =
DIVIDE(
    [Persona Revenue],
    CALCULATE(
        [Persona Revenue],
        ALLSELECTED(FactSales[Persona])
    ),
    0
)

Persona Growth % =
DIVIDE(
    [Persona Revenue] - [Persona Revenue Previous Period],
    [Persona Revenue Previous Period],
    0
)

Branch Performance

Branch performance measures are used to evaluate actual revenue against branch revenue targets and identify over- and under-performing branches.

Branch Target Variance % =
DIVIDE(
    [Total Revenue] - [Branch Target],
    [Branch Target],
    0
)

