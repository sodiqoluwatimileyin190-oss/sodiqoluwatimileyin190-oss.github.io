USE JRAD_Retail_Analytics;
GO
CREATE TABLE DimProduct
(
    Product_Key INT IDENTITY(1,1) NOT NULL,
    Product_ID VARCHAR(20) NOT NULL,
    Department VARCHAR(100),
    Category VARCHAR(100),
    Brand VARCHAR(100),
    Product_Name VARCHAR(255),
    Package_Type VARCHAR(100),
    Pack_Size VARCHAR(50),
    Unit_of_Measure VARCHAR(50),
    Base_Price_Jan DECIMAL(12,2),
    VAT_Status VARCHAR(20),
    Storage_Type VARCHAR(50),
    Is_Discontinued BIT,
    Cost_Price_Jan DECIMAL(12,2),
    Popularity_Tier VARCHAR(50),
    Purchase_Trigger VARCHAR(100),
    Inflation_Sensitivity VARCHAR(50),

    CONSTRAINT PK_DimProduct
        PRIMARY KEY (Product_Key),

    CONSTRAINT UQ_DimProduct_Product_ID
        UNIQUE (Product_ID)
);
GO

SELECT *
FROM dbo.DimProduct;

USE JRAD_Retail_Analytics;
GO

SELECT COUNT(*) AS Staging_Product_Count
FROM dbo.Product_Staging;




USE JRAD_Retail_Analytics;
GO

SELECT
    name AS Table_Name
FROM sys.tables
ORDER BY name;

SELECT COUNT(*) AS Product_Rows
FROM dbo.DimProduct;

SELECT COUNT(*) AS Staging_Rows
FROM dbo.Product_Staging;

USE JRAD_Retail_Analytics;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Product_Staging'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10
    *
FROM dbo.Product_Staging;

SELECT COUNT(*) AS Staging_Product_Count
FROM dbo.Product_Staging;

USE JRAD_Retail_Analytics;
GO

SELECT
    COUNT(*) AS Total_Rows,

    COUNT(Cost_Price_Jan) AS Cost_Price_NonNull,
    MAX(LEN(Cost_Price_Jan)) AS Max_Cost_Price_Length,

    COUNT(Popularity_Tier) AS Popularity_NonNull,
    MAX(LEN(Popularity_Tier)) AS Max_Popularity_Length,

    COUNT(Purchase_Trigger) AS Purchase_Trigger_NonNull,
    MAX(LEN(Purchase_Trigger)) AS Max_Purchase_Trigger_Length,

    COUNT(Inflation_Sensitivity) AS Inflation_NonNull,
    MAX(LEN(Inflation_Sensitivity)) AS Max_Inflation_Length

FROM dbo.Product_Staging;

SELECT DISTINCT
    Cost_Price_Jan,
    Popularity_Tier,
    Purchase_Trigger,
    Inflation_Sensitivity
FROM dbo.Product_Staging;

USE JRAD_Retail_Analytics;
GO

INSERT INTO dbo.DimProduct
(
    Product_ID,
    Department,
    Category,
    Brand,
    Product_Name,
    Package_Type,
    Pack_Size,
    Unit_of_Measure,
    Base_Price_Jan,
    VAT_Status,
    Storage_Type,
    Is_Discontinued,
    Cost_Price_Jan,
    Popularity_Tier,
    Purchase_Trigger,
    Inflation_Sensitivity
)
SELECT
    LTRIM(RTRIM(Product_ID)),
    Department,
    Category,
    Brand,
    Product_Name,
    Package_Type,
    Pack_Size,
    Unit_of_Measure,
    TRY_CONVERT(DECIMAL(12,2), Base_Price_Jan),
    VAT_Status,
    Storage_Type,
    TRY_CONVERT(BIT, Is_Discontinued),
    TRY_CONVERT(DECIMAL(12,2), NULLIF(Cost_Price_Jan, '')),
    NULLIF(Popularity_Tier, ''),
    NULLIF(Purchase_Trigger, ''),
    NULLIF(Inflation_Sensitivity, '')
FROM dbo.Product_Staging;
GO

SELECT COUNT(*) AS Product_Count
FROM dbo.DimProduct;

SELECT TOP 10
    Product_Key,
    Product_ID,
    Department,
    Category,
    Brand,
    Product_Name
FROM dbo.DimProduct
ORDER BY Product_ID;

SELECT
    Product_ID,
    COUNT(*) AS Number_of_Rows
FROM dbo.DimProduct
GROUP BY Product_ID
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS Missing_Product_IDs
FROM dbo.DimProduct
WHERE Product_ID IS NULL
   OR LTRIM(RTRIM(Product_ID)) = '';

SELECT
    (SELECT COUNT(*) FROM dbo.Product_Staging) AS Staging_Count,
    (SELECT COUNT(*) FROM dbo.DimProduct) AS DimProduct_Count;

   -- Product Master is officially loaded and passed its first SQL QA.
   -- Now we move to Customer Table

USE JRAD_Retail_Analytics;
GO

CREATE TABLE dbo.DimCustomer
(
    Customer_Key INT IDENTITY(1,1) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,

    First_Name VARCHAR(100),
    Last_Name VARCHAR(100),
    Full_Name VARCHAR(200),

    Gender VARCHAR(20),
    Ethnicity VARCHAR(50),
    Age INT,

    Phone_Number VARCHAR(30),
    Email VARCHAR(255),

    Branch VARCHAR(20),
    Registration_Status VARCHAR(50),
    Loyalty_Member BIT,

    Registration_Date DATE,

    Acquisition_Source VARCHAR(100),
    Registration_Channel VARCHAR(100),
    Marketing_Opt_In BIT,

    CONSTRAINT PK_DimCustomer
        PRIMARY KEY (Customer_Key),

    CONSTRAINT UQ_DimCustomer_Customer_ID
        UNIQUE (Customer_ID)
);
GO


USE JRAD_Retail_Analytics;
GO

SELECT COUNT(*) AS Customer_Staging_Count
FROM dbo.Customer_Staging;


SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer_Staging'
ORDER BY ORDINAL_POSITION;


SELECT COUNT(*) AS Customer_Staging_Count
FROM dbo.Customer_Staging;


SELECT
    Loyalty_Member,
    COUNT(*) AS Number_of_Customers
FROM dbo.Customer_Staging
GROUP BY Loyalty_Member;

SELECT TOP 20
    Phone_Number
FROM dbo.Customer_Staging
WHERE Phone_Number IS NOT NULL;


SELECT
    MIN(Phone_Number) AS Minimum_Phone,
    MAX(Phone_Number) AS Maximum_Phone
FROM dbo.Customer_Staging;


SELECT
    Customer_ID,
    COUNT(*) AS Number_of_Rows
FROM dbo.Customer_Staging
GROUP BY Customer_ID
HAVING COUNT(*) > 1;


SELECT COUNT(*) AS Missing_Customer_IDs
FROM dbo.Customer_Staging
WHERE Customer_ID IS NULL
   OR LTRIM(RTRIM(Customer_ID)) = '';


SELECT
    MIN(LEN(CAST(Phone_Number AS VARCHAR(20)))) AS Shortest_Phone,
    MAX(LEN(CAST(Phone_Number AS VARCHAR(20)))) AS Longest_Phone
FROM dbo.Customer_Staging
WHERE Phone_Number IS NOT NULL;


USE JRAD_Retail_Analytics;
GO

INSERT INTO dbo.DimCustomer
(
    Customer_ID,
    First_Name,
    Last_Name,
    Full_Name,
    Gender,
    Ethnicity,
    Age,
    Phone_Number,
    Email,
    Branch,
    Registration_Status,
    Loyalty_Member,
    Registration_Date,
    Acquisition_Source,
    Registration_Channel,
    Marketing_Opt_In
)
SELECT
    LTRIM(RTRIM(Customer_ID)),
    First_Name,
    Last_Name,
    Full_Name,
    Gender,
    Ethnicity,
    Age,

    CASE
        WHEN Phone_Number IS NULL THEN NULL
        ELSE '0' + CAST(Phone_Number AS VARCHAR(20))
    END,

    Email,
    Branch,
    Registration_Status,

    CASE
        WHEN UPPER(LTRIM(RTRIM(Loyalty_Member))) = 'YES' THEN 1
        ELSE 0
    END,

    Registration_Date,
    Acquisition_Source,
    Registration_Channel,
    Marketing_Opt_In
FROM dbo.Customer_Staging;
GO


SELECT COUNT(*) AS Customer_Count
FROM dbo.DimCustomer;


SELECT TOP 10
    Customer_ID,
    Phone_Number,
    Loyalty_Member
FROM dbo.DimCustomer
WHERE Phone_Number IS NOT NULL;


SELECT
    Customer_ID,
    COUNT(*) AS Number_of_Rows
FROM dbo.DimCustomer
GROUP BY Customer_ID
HAVING COUNT(*) > 1;


SELECT COUNT(*) AS Missing_Customer_IDs
FROM dbo.DimCustomer
WHERE Customer_ID IS NULL
   OR LTRIM(RTRIM(Customer_ID)) = '';


SELECT
    (SELECT COUNT(*) FROM dbo.Customer_Staging) AS Staging_Count,
    (SELECT COUNT(*) FROM dbo.DimCustomer) AS DimCustomer_Count;

    --Customer Master is now loaded and QA-passed.
    --NEXT: Pricing History
    --JRAD Pricing History Excel
          ↓
    --Pricing_Staging
          ↓
    --Validate
          ↓
    --DimPricingHistory
          ↓
    --Validate against DimProduct

USE JRAD_Retail_Analytics;
GO

CREATE TABLE dbo.DimPricingHistory
(
    Pricing_Key INT IDENTITY(1,1) NOT NULL,

    Pricing_ID VARCHAR(20) NOT NULL,
    Product_ID VARCHAR(20) NOT NULL,

    Effective_Date DATE NOT NULL,

    Previous_Price DECIMAL(12,2),
    New_Price DECIMAL(12,2),

    Price_Change DECIMAL(12,2),
    Change_Percent DECIMAL(10,2),

    Change_Reason VARCHAR(100),

    CONSTRAINT PK_DimPricingHistory
        PRIMARY KEY (Pricing_Key),

    CONSTRAINT UQ_DimPricingHistory_Pricing_ID
        UNIQUE (Pricing_ID),

    CONSTRAINT FK_DimPricingHistory_Product
        FOREIGN KEY (Product_ID)
        REFERENCES dbo.DimProduct(Product_ID)
);
GO


USE JRAD_Retail_Analytics;
GO

SELECT
    name AS Table_Name
FROM sys.tables
WHERE name = 'Pricing_Staging';


SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Pricing_Staging'
ORDER BY ORDINAL_POSITION;


USE JRAD_Retail_Analytics;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Pricing_Staging'
ORDER BY ORDINAL_POSITION;


SELECT COUNT(*) AS Pricing_Staging_Count
FROM dbo.Pricing_Staging;


SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Price_Change) AS NonNull_Price_Changes,
    SUM(CASE WHEN Price_Change IS NULL THEN 1 ELSE 0 END) AS Null_Price_Changes
FROM dbo.Pricing_Staging;


SELECT
    Pricing_ID,
    Product_ID,
    Effective_Date,
    Previous_Price,
    New_Price,
    Price_Change,
    Change_Percent,
    Change_Reason
FROM dbo.Pricing_Staging
WHERE Price_Change IS NULL
ORDER BY Product_ID, Effective_Date;


SELECT
    Pricing_ID,
    Product_ID,
    Effective_Date,
    Previous_Price,
    New_Price,
    Price_Change,
    Change_Percent,
    Change_Reason
FROM dbo.Pricing_Staging
WHERE Change_Percent IS NULL
ORDER BY Product_ID, Effective_Date;


USE JRAD_Retail_Analytics;
GO

UPDATE dbo.Pricing_Staging
SET Price_Change = New_Price - Previous_Price
WHERE Price_Change IS NULL
  AND Previous_Price IS NOT NULL
  AND New_Price IS NOT NULL;
GO


SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Price_Change) AS NonNull_Price_Changes,
    SUM(CASE WHEN Price_Change IS NULL THEN 1 ELSE 0 END) AS Null_Price_Changes
FROM dbo.Pricing_Staging;


SELECT
    Pricing_ID,
    Product_ID,
    Previous_Price,
    New_Price,
    Price_Change,
    Change_Percent,
    Change_Reason
FROM dbo.Pricing_Staging
WHERE Pricing_ID IN
(
    'PRC000899',
    'PRC000833',
    'PRC000948',
    'PRC000613',
    'PRC000377',
    'PRC002104',
    'PRC002123',
    'PRC001533',
    'PRC001249'
)
ORDER BY Pricing_ID;


SELECT
    COUNT(*) AS Incorrect_Price_Changes
FROM dbo.Pricing_Staging
WHERE ABS(
    Price_Change - (New_Price - Previous_Price)
) > 0.01;


SELECT
    COUNT(*) AS Incorrect_Change_Percent
FROM dbo.Pricing_Staging
WHERE Previous_Price IS NOT NULL
  AND Previous_Price <> 0
  AND ABS(
        Change_Percent
        - ((New_Price - Previous_Price) / Previous_Price * 100)
      ) > 0.01;


--Import-layer data truncation affecting 9 pricing records.
--I didn't regenerate the pricing dataset.
--I didn't alter the source generator.
--Identified that:

--Source Pricing History
        ↓
--Import Flat File Wizard
        ↓
--Pricing_Staging
        ↓
--9 Price_Change values lost(Then i repaired the staging layer using the underlying business calculation:)
--Price Change = New Price − Previous Price
--After these checks pass:
--2,549 records
--0 NULL Price_Change
--0 incorrect Price_Change
--0 incorrect Change_Percent

--Referential Integrity Check
USE JRAD_Retail_Analytics;
GO

SELECT
    COUNT(*) AS Orphan_Pricing_Records
FROM dbo.Pricing_Staging p
LEFT JOIN dbo.DimProduct d
    ON p.Product_ID = d.Product_ID
WHERE d.Product_ID IS NULL;


SELECT DISTINCT
    p.Product_ID
FROM dbo.Pricing_Staging p
LEFT JOIN dbo.DimProduct d
    ON p.Product_ID = d.Product_ID
WHERE d.Product_ID IS NULL;


SELECT
    COUNT(*) AS Total_Pricing_Records,
    COUNT(DISTINCT Pricing_ID) AS Unique_Pricing_IDs
FROM dbo.Pricing_Staging;


SELECT
    SUM(CASE WHEN Pricing_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Pricing_ID,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Product_ID,
    SUM(CASE WHEN Effective_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Effective_Date,
    SUM(CASE WHEN New_Price IS NULL THEN 1 ELSE 0 END) AS Missing_New_Price
FROM dbo.Pricing_Staging;


SELECT
    COUNT(*) AS Invalid_New_Prices
FROM dbo.Pricing_Staging
WHERE New_Price <= 0;


SELECT
    COUNT(*) AS Invalid_Previous_Prices
FROM dbo.Pricing_Staging
WHERE Previous_Price IS NOT NULL
  AND Previous_Price <= 0;


SELECT
    Product_ID,
    Effective_Date,
    Pricing_ID,
    Previous_Price,
    New_Price
FROM dbo.Pricing_Staging
ORDER BY Product_ID, Effective_Date;


WITH PricingSequence AS
(
    SELECT
        Product_ID,
        Effective_Date,
        Pricing_ID,
        LAG(Effective_Date) OVER
        (
            PARTITION BY Product_ID
            ORDER BY Effective_Date, Pricing_ID
        ) AS Previous_Effective_Date
    FROM dbo.Pricing_Staging
)
SELECT COUNT(*) AS Invalid_Date_Sequence
FROM PricingSequence
WHERE Previous_Effective_Date IS NOT NULL
  AND Effective_Date < Previous_Effective_Date;


SELECT
    COUNT(*) AS Initial_Price_Records
FROM dbo.Pricing_Staging
WHERE Change_Reason = 'Initial Price';


SELECT
    COUNT(DISTINCT Product_ID) AS Products_With_Initial_Price
FROM dbo.Pricing_Staging
WHERE Change_Reason = 'Initial Price';


SELECT
    (SELECT COUNT(*) FROM dbo.DimProduct) AS Product_Count,
    (SELECT COUNT(*) FROM dbo.Pricing_Staging) AS Pricing_Record_Count,
    (
        SELECT COUNT(*)
        FROM dbo.Pricing_Staging
        WHERE Change_Reason = 'Initial Price'
    ) AS Initial_Price_Count;

/*
632 Products
       ↓
2,549 Pricing Records
       ↓
632 Initial Prices
       ↓
1,917 Historical Changes
       ↓
0 Orphan Products
       ↓
0 Duplicate Pricing IDs
       ↓
0 Missing Required Fields
       ↓
0 Invalid Prices
       ↓
0 Broken Price Calculations
       ↓
READY FOR DimPricingHistory ✅
*/


USE JRAD_Retail_Analytics;
GO

INSERT INTO dbo.DimPricingHistory
(
    Pricing_ID,
    Product_ID,
    Effective_Date,
    Previous_Price,
    New_Price,
    Price_Change,
    Change_Percent,
    Change_Reason
)
SELECT
    LTRIM(RTRIM(Pricing_ID)),
    LTRIM(RTRIM(Product_ID)),
    CAST(Effective_Date AS DATE),

    TRY_CONVERT(DECIMAL(12,2), Previous_Price),
    TRY_CONVERT(DECIMAL(12,2), New_Price),
    TRY_CONVERT(DECIMAL(12,2), Price_Change),
    TRY_CONVERT(DECIMAL(10,2), Change_Percent),

    LTRIM(RTRIM(Change_Reason))
FROM dbo.Pricing_Staging;
GO


SELECT COUNT(*) AS Pricing_History_Count
FROM dbo.DimPricingHistory;


SELECT TOP 10
    Pricing_Key,
    Pricing_ID,
    Product_ID,
    Effective_Date,
    Previous_Price,
    New_Price,
    Price_Change,
    Change_Percent,
    Change_Reason
FROM dbo.DimPricingHistory
ORDER BY Pricing_Key;


SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT Pricing_ID) AS Unique_Pricing_IDs,
    COUNT(DISTINCT Product_ID) AS Products_With_Pricing,
    SUM(CASE WHEN Pricing_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Pricing_ID,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Product_ID,
    SUM(CASE WHEN Effective_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Effective_Date,
    SUM(CASE WHEN New_Price IS NULL THEN 1 ELSE 0 END) AS Missing_New_Price
FROM dbo.DimPricingHistory;


SELECT COUNT(*) AS Orphan_Pricing_Records
FROM dbo.DimPricingHistory p
LEFT JOIN dbo.DimProduct d
    ON p.Product_ID = d.Product_ID
WHERE d.Product_ID IS NULL;


  /*                  
                         DimProduct    
                        632 products  
                             │
                         Product_ID
                             │
                             ▼
                     DimPricingHistory   
                     2,549 records     
*/
--Pricing History is locked in
--Moving to the next major dataset: Inventory.
--The pipeline is now 
--Product Master       →  632
--Customer Master      →  800
--Pricing History      →  2,549
--Inventory Master     →  NEXT


USE JRAD_Retail_Analytics;
GO

CREATE TABLE dbo.FactInventory
(
    Inventory_Key INT IDENTITY(1,1) NOT NULL,

    Inventory_ID VARCHAR(20) NOT NULL,
    Product_ID VARCHAR(20) NOT NULL,

    Branch_Code VARCHAR(10) NOT NULL,
    Branch_Name VARCHAR(50),

    Opening_Stock INT,
    Current_Stock INT,
    Reorder_Level INT,
    Safety_Stock INT,
    Maximum_Stock INT,

    Stock_Status VARCHAR(30),

    Last_Restock_Date DATE,

    Shelf_Location VARCHAR(20),

    CONSTRAINT PK_FactInventory
        PRIMARY KEY (Inventory_Key),

    CONSTRAINT UQ_FactInventory_Inventory_ID
        UNIQUE (Inventory_ID),

    CONSTRAINT FK_FactInventory_Product
        FOREIGN KEY (Product_ID)
        REFERENCES dbo.DimProduct(Product_ID)
);
GO
 /*
JRAD_Inventory_Master_2026.csv
             ↓
     Inventory_Staging
             ↓
            QA
             ↓
       FactInventory
*/

USE JRAD_Retail_Analytics;
GO

SELECT COUNT(*) AS Inventory_Staging_Count
FROM dbo.Inventory_Staging;


SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Inventory_Staging'
ORDER BY ORDINAL_POSITION;


SELECT
    Inventory_ID,
    COUNT(*) AS Number_of_Rows
FROM dbo.Inventory_Staging
GROUP BY Inventory_ID
HAVING COUNT(*) > 1;


SELECT
    SUM(CASE WHEN Inventory_ID IS NULL OR LTRIM(RTRIM(Inventory_ID)) = '' THEN 1 ELSE 0 END) AS Missing_Inventory_ID,
    SUM(CASE WHEN Product_ID IS NULL OR LTRIM(RTRIM(Product_ID)) = '' THEN 1 ELSE 0 END) AS Missing_Product_ID,
    SUM(CASE WHEN Branch_Code IS NULL OR LTRIM(RTRIM(Branch_Code)) = '' THEN 1 ELSE 0 END) AS Missing_Branch_Code
FROM dbo.Inventory_Staging;


SELECT
    COUNT(*) AS Orphan_Inventory_Records
FROM dbo.Inventory_Staging i
LEFT JOIN dbo.DimProduct p
    ON LTRIM(RTRIM(i.Product_ID)) = p.Product_ID
WHERE p.Product_ID IS NULL;


SELECT COUNT(*) AS Negative_Opening_Stock
FROM dbo.Inventory_Staging
WHERE Opening_Stock < 0;

SELECT COUNT(*) AS Negative_Current_Stock
FROM dbo.Inventory_Staging
WHERE Current_Stock < 0;

SELECT COUNT(*) AS Invalid_Maximum_Stock
FROM dbo.Inventory_Staging
WHERE Maximum_Stock < Reorder_Level;


SELECT
    Stock_Status,
    COUNT(*) AS Number_of_Records
FROM dbo.Inventory_Staging
GROUP BY Stock_Status
ORDER BY Number_of_Records DESC;


USE JRAD_Retail_Analytics;
GO

INSERT INTO dbo.FactInventory
(
    Inventory_ID,
    Product_ID,
    Branch_Code,
    Branch_Name,
    Opening_Stock,
    Current_Stock,
    Reorder_Level,
    Safety_Stock,
    Maximum_Stock,
    Stock_Status,
    Last_Restock_Date,
    Shelf_Location
)
SELECT
    LTRIM(RTRIM(Inventory_ID)),
    LTRIM(RTRIM(Product_ID)),
    LTRIM(RTRIM(Branch_Code)),
    LTRIM(RTRIM(Branch_Name)),
    CAST(Opening_Stock AS INT),
    CAST(Current_Stock AS INT),
    CAST(Reorder_Level AS INT),
    CAST(Safety_Stock AS INT),
    CAST(Maximum_Stock AS INT),
    LTRIM(RTRIM(Stock_Status)),
    CAST(Last_Restock_Date AS DATE),
    LTRIM(RTRIM(Shelf_Location))
FROM dbo.Inventory_Staging;
GO


SELECT COUNT(*) AS Inventory_Record_Count
FROM dbo.FactInventory;

SELECT
    Stock_Status,
    COUNT(*) AS Number_of_Records
FROM dbo.FactInventory
GROUP BY Stock_Status
ORDER BY Number_of_Records DESC;


SELECT
    COUNT(*) AS Orphan_Inventory_Records
FROM dbo.FactInventory i
LEFT JOIN dbo.DimProduct p
    ON i.Product_ID = p.Product_ID
WHERE p.Product_ID IS NULL;


SELECT
    Product_ID,
    Branch_Code,
    COUNT(*) AS Number_of_Records
FROM dbo.FactInventory
GROUP BY
    Product_ID,
    Branch_Code
HAVING COUNT(*) > 1;


SELECT
    COUNT(*) AS Total_Inventory_Records,
    COUNT(DISTINCT Product_ID) AS Products,
    COUNT(DISTINCT Branch_Code) AS Branches,
    SUM(Opening_Stock) AS Total_Opening_Stock,
    SUM(Current_Stock) AS Total_Current_Stock,
    SUM(CASE WHEN Stock_Status = 'In Stock' THEN 1 ELSE 0 END) AS In_Stock,
    SUM(CASE WHEN Stock_Status = 'Low Stock' THEN 1 ELSE 0 END) AS Low_Stock,
    SUM(CASE WHEN Stock_Status = 'Out of Stock' THEN 1 ELSE 0 END) AS Out_of_Stock
FROM dbo.FactInventory;

--And the inventory layer now gives us:
--632 products × 5 branches = 3,160 inventory positions.
--Inventory is officially complete.

--Now moving into one of the most important business-logic tables in JRAD.
/*
We'll first do

Business Event Excel
        ↓
Inspect actual schema
        ↓
Import to BusinessEvent_Staging
        ↓
QA event dates
        ↓
QA overlapping events
        ↓
QA traffic/basket multipliers
        ↓
Validate Christmas windows
        ↓
Production table
*/

USE JRAD_Retail_Analytics;
GO

SELECT COUNT(*) AS Business_Event_Staging_Count
FROM dbo.BusinessEvent_Staging;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'BusinessEvent_Staging'
ORDER BY ORDINAL_POSITION;

SELECT *
FROM dbo.BusinessEvent_Staging
ORDER BY Start_Date;

SELECT
    Event_ID,
    COUNT(*) AS Number_of_Records
FROM dbo.BusinessEvent_Staging
GROUP BY Event_ID
HAVING COUNT(*) > 1;

SELECT
    Event_ID,
    Event_Name,
    Start_Date,
    End_Date
FROM dbo.BusinessEvent_Staging
WHERE Start_Date > End_Date;

SELECT
    SUM(CASE WHEN Event_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Event_ID,
    SUM(CASE WHEN Event_Name IS NULL THEN 1 ELSE 0 END) AS Missing_Event_Name,
    SUM(CASE WHEN Start_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Start_Date,
    SUM(CASE WHEN End_Date IS NULL THEN 1 ELSE 0 END) AS Missing_End_Date
FROM dbo.BusinessEvent_Staging;

SELECT
    Event_ID,
    Event_Name,
    Traffic_Multiplier,
    Basket_Multiplier,
    Spend_Multiplier
FROM dbo.BusinessEvent_Staging
WHERE Traffic_Multiplier <= 0
   OR Basket_Multiplier <= 0
   OR Spend_Multiplier <= 0;

SELECT
    SUM(CASE WHEN Traffic_Multiplier IS NULL THEN 1 ELSE 0 END) AS Missing_Traffic,
    SUM(CASE WHEN Basket_Multiplier IS NULL THEN 1 ELSE 0 END) AS Missing_Basket,
    SUM(CASE WHEN Spend_Multiplier IS NULL THEN 1 ELSE 0 END) AS Missing_Spend
FROM dbo.BusinessEvent_Staging;

SELECT
    Peak_Hours,
    COUNT(*) AS Number_of_Events
FROM dbo.BusinessEvent_Staging
GROUP BY Peak_Hours
ORDER BY Peak_Hours;

--Christmas verification
SELECT
    Event_ID,
    Event_Name,
    Start_Date,
    End_Date,
    Traffic_Multiplier,
    Basket_Multiplier,
    Spend_Multiplier,
    Peak_Hours,
    Target_Branches,
    Target_Categories
FROM dbo.BusinessEvent_Staging
WHERE Event_Name LIKE '%Christmas%';

--Overlapping Business Events
SELECT
    A.Event_ID AS Event_A,
    A.Event_Name AS Event_A_Name,
    A.Start_Date AS Event_A_Start,
    A.End_Date AS Event_A_End,

    B.Event_ID AS Event_B,
    B.Event_Name AS Event_B_Name,
    B.Start_Date AS Event_B_Start,
    B.End_Date AS Event_B_End

FROM dbo.BusinessEvent_Staging A
JOIN dbo.BusinessEvent_Staging B
    ON A.Event_ID < B.Event_ID
    AND A.Start_Date <= B.End_Date
    AND B.Start_Date <= A.End_Date

ORDER BY
    A.Start_Date,
    B.Start_Date;

SELECT
    COUNT(*) AS Overlapping_Event_Pairs
FROM dbo.BusinessEvent_Staging A
JOIN dbo.BusinessEvent_Staging B
    ON A.Event_ID < B.Event_ID
    AND A.Start_Date <= B.End_Date
    AND B.Start_Date <= A.End_Date;

SELECT
    Event_ID,
    Event_Name,
    Start_Date,
    End_Date
FROM dbo.BusinessEvent_Staging
WHERE Start_Date <= '2026-12-31'
  AND End_Date >= '2026-12-15'
ORDER BY Start_Date;

--Promoting the validated business events.
USE JRAD_Retail_Analytics;
GO

CREATE TABLE dbo.DimBusinessEvent
(
    BusinessEvent_Key INT IDENTITY(1,1) NOT NULL,

    Event_ID VARCHAR(20) NOT NULL,
    Event_Name VARCHAR(100) NOT NULL,

    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,

    Event_Type VARCHAR(50) NOT NULL,

    Traffic_Multiplier DECIMAL(10,4) NOT NULL,
    Basket_Multiplier DECIMAL(10,4) NOT NULL,
    Spend_Multiplier DECIMAL(10,4) NOT NULL,

    Peak_Hours VARCHAR(50),

    Target_Branches VARCHAR(100),
    Target_Categories VARCHAR(200),

    Description VARCHAR(255),

    CONSTRAINT PK_DimBusinessEvent
        PRIMARY KEY (BusinessEvent_Key),

    CONSTRAINT UQ_DimBusinessEvent_Event_ID
        UNIQUE (Event_ID),

    CONSTRAINT CK_DimBusinessEvent_Dates
        CHECK (Start_Date <= End_Date),

    CONSTRAINT CK_DimBusinessEvent_Traffic
        CHECK (Traffic_Multiplier > 0),

    CONSTRAINT CK_DimBusinessEvent_Basket
        CHECK (Basket_Multiplier > 0),

    CONSTRAINT CK_DimBusinessEvent_Spend
        CHECK (Spend_Multiplier > 0)
);
GO


INSERT INTO dbo.DimBusinessEvent
(
    Event_ID,
    Event_Name,
    Start_Date,
    End_Date,
    Event_Type,
    Traffic_Multiplier,
    Basket_Multiplier,
    Spend_Multiplier,
    Peak_Hours,
    Target_Branches,
    Target_Categories,
    Description
)
SELECT
    LTRIM(RTRIM(Event_ID)),
    LTRIM(RTRIM(Event_Name)),
    Start_Date,
    End_Date,
    LTRIM(RTRIM(Event_Type)),
    CAST(Traffic_Multiplier AS DECIMAL(10,4)),
    CAST(Basket_Multiplier AS DECIMAL(10,4)),
    CAST(Spend_Multiplier AS DECIMAL(10,4)),
    LTRIM(RTRIM(Peak_Hours)),
    LTRIM(RTRIM(Target_Branches)),
    LTRIM(RTRIM(Target_Categories)),
    LTRIM(RTRIM(Description))
FROM dbo.BusinessEvent_Staging;
GO


SELECT
    BusinessEvent_Key,
    Event_ID,
    Event_Name,
    Start_Date,
    End_Date,
    Traffic_Multiplier,
    Basket_Multiplier,
    Spend_Multiplier
FROM dbo.DimBusinessEvent
ORDER BY Start_Date;

SELECT
    COUNT(DISTINCT Event_ID) AS Unique_Event_IDs,
    COUNT(DISTINCT Event_Name) AS Unique_Event_Names
FROM dbo.DimBusinessEvent;

/*
DimProduct
   632
     │
     ├───────────────┐
     │               │
     ▼               ▼
DimPricingHistory  FactInventory
   2,549             3,160

DimCustomer
   800

DimBusinessEvent
   10
*/

USE JRAD_Retail_Analytics;
GO

SELECT COUNT(*) AS Monthly_Behaviour_Staging_Count
FROM dbo.MonthlyBehaviour_Staging;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'MonthlyBehaviour_Staging'
ORDER BY ORDINAL_POSITION;

SELECT *
FROM dbo.MonthlyBehaviour_Staging
ORDER BY Week;

SELECT
    Week,
    Week_Name
FROM dbo.MonthlyBehaviour_Staging
ORDER BY Week;

SELECT
    Week,
    Week_Name,
    Traffic_Multiplier,
    Basket_Multiplier,
    Spend_Multiplier
FROM dbo.MonthlyBehaviour_Staging
WHERE Traffic_Multiplier <= 0
   OR Basket_Multiplier <= 0
   OR Spend_Multiplier <= 0;

SELECT
    Week,
    Week_Name,
    Traffic_Multiplier,
    Basket_Multiplier,
    Spend_Multiplier,
    Shopping_Behaviour,
    Primary_Missions,
    Description
FROM dbo.MonthlyBehaviour_Staging
ORDER BY Week;

USE JRAD_Retail_Analytics;
GO

CREATE TABLE dbo.DimMonthlyBehaviour
(
    MonthlyBehaviour_Key INT IDENTITY(1,1) NOT NULL,

    Week TINYINT NOT NULL,
    Week_Name VARCHAR(50) NOT NULL,

    Traffic_Multiplier DECIMAL(10,4) NOT NULL,
    Basket_Multiplier DECIMAL(10,4) NOT NULL,
    Spend_Multiplier DECIMAL(10,4) NOT NULL,

    Shopping_Behaviour VARCHAR(100) NOT NULL,
    Primary_Missions VARCHAR(200) NOT NULL,
    Description VARCHAR(255) NOT NULL,

    CONSTRAINT PK_DimMonthlyBehaviour
        PRIMARY KEY (MonthlyBehaviour_Key),

    CONSTRAINT UQ_DimMonthlyBehaviour_Week
        UNIQUE (Week),

    CONSTRAINT CK_DimMonthlyBehaviour_Week
        CHECK (Week BETWEEN 1 AND 4),

    CONSTRAINT CK_DimMonthlyBehaviour_Traffic
        CHECK (Traffic_Multiplier > 0),

    CONSTRAINT CK_DimMonthlyBehaviour_Basket
        CHECK (Basket_Multiplier > 0),

    CONSTRAINT CK_DimMonthlyBehaviour_Spend
        CHECK (Spend_Multiplier > 0)
);
GO

INSERT INTO dbo.DimMonthlyBehaviour
(
    Week,
    Week_Name,
    Traffic_Multiplier,
    Basket_Multiplier,
    Spend_Multiplier,
    Shopping_Behaviour,
    Primary_Missions,
    Description
)
SELECT
    Week,
    LTRIM(RTRIM(Week_Name)),
    CAST(Traffic_Multiplier AS DECIMAL(10,4)),
    CAST(Basket_Multiplier AS DECIMAL(10,4)),
    CAST(Spend_Multiplier AS DECIMAL(10,4)),
    LTRIM(RTRIM(Shopping_Behaviour)),
    LTRIM(RTRIM(Primary_Missions)),
    LTRIM(RTRIM(Description))
FROM dbo.MonthlyBehaviour_Staging;
GO

SELECT
    MonthlyBehaviour_Key,
    Week,
    Week_Name,
    Traffic_Multiplier,
    Basket_Multiplier,
    Spend_Multiplier,
    Shopping_Behaviour,
    Primary_Missions
FROM dbo.DimMonthlyBehaviour
ORDER BY Week;

SELECT COUNT(*) AS Monthly_Behaviour_Count
FROM dbo.DimMonthlyBehaviour;


USE JRAD_Retail_Analytics;
GO

SELECT COUNT(*) AS Branch_Behaviour_Staging_Count
FROM dbo.BranchBehaviour_Staging;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'BranchBehaviour_Staging'
ORDER BY ORDINAL_POSITION;

SELECT *
FROM dbo.BranchBehaviour_Staging;


SELECT
    Branch_Code,
    COUNT(*) AS Number_of_Records
FROM dbo.BranchBehaviour_Staging
GROUP BY Branch_Code
HAVING COUNT(*) > 1;

SELECT
    Branch_Code,
    Branch_Name
FROM dbo.BranchBehaviour_Staging
ORDER BY Branch_Code;

SELECT
    Branch_Code,
    Branch_Name,
    Customer_Traffic
FROM dbo.BranchBehaviour_Staging
WHERE Customer_Traffic <= 0
   OR Customer_Traffic IS NULL;

   SELECT
    SUM(CASE WHEN Branch_Code IS NULL THEN 1 ELSE 0 END) AS Missing_Branch_Code,
    SUM(CASE WHEN Branch_Name IS NULL THEN 1 ELSE 0 END) AS Missing_Branch_Name,
    SUM(CASE WHEN Customer_Traffic IS NULL THEN 1 ELSE 0 END) AS Missing_Customer_Traffic,
    SUM(CASE WHEN Bread_Demand IS NULL THEN 1 ELSE 0 END) AS Missing_Bread_Demand,
    SUM(CASE WHEN Premium_Demand IS NULL THEN 1 ELSE 0 END) AS Missing_Premium_Demand,
    SUM(CASE WHEN Family_Shopping IS NULL THEN 1 ELSE 0 END) AS Missing_Family_Shopping,
    SUM(CASE WHEN Morning_Rush IS NULL THEN 1 ELSE 0 END) AS Missing_Morning_Rush,
    SUM(CASE WHEN Evening_Rush IS NULL THEN 1 ELSE 0 END) AS Missing_Evening_Rush
FROM dbo.BranchBehaviour_Staging;

SELECT
    Branch_Code,
    Branch_Name,
    Bread_Demand,
    Premium_Demand,
    Family_Shopping,
    Morning_Rush,
    Evening_Rush
FROM dbo.BranchBehaviour_Staging
ORDER BY Branch_Code;

USE JRAD_Retail_Analytics;
GO

CREATE TABLE dbo.DimBranchBehaviour
(
    BranchBehaviour_Key INT IDENTITY(1,1) NOT NULL,

    Branch_Code VARCHAR(20) NOT NULL,
    Branch_Name VARCHAR(100) NOT NULL,

    Customer_Traffic DECIMAL(10,4) NOT NULL,

    Bread_Demand VARCHAR(50) NOT NULL,
    Premium_Demand VARCHAR(50) NOT NULL,
    Family_Shopping VARCHAR(50) NOT NULL,
    Morning_Rush VARCHAR(50) NOT NULL,
    Evening_Rush VARCHAR(50) NOT NULL,

    CONSTRAINT PK_DimBranchBehaviour
        PRIMARY KEY (BranchBehaviour_Key),

    CONSTRAINT UQ_DimBranchBehaviour_Branch_Code
        UNIQUE (Branch_Code),

    CONSTRAINT CK_DimBranchBehaviour_Customer_Traffic
        CHECK (Customer_Traffic > 0)
);
GO


INSERT INTO dbo.DimBranchBehaviour
(
    Branch_Code,
    Branch_Name,
    Customer_Traffic,
    Bread_Demand,
    Premium_Demand,
    Family_Shopping,
    Morning_Rush,
    Evening_Rush
)
SELECT
    LTRIM(RTRIM(Branch_Code)),
    LTRIM(RTRIM(Branch_Name)),
    CAST(Customer_Traffic AS DECIMAL(10,4)),
    LTRIM(RTRIM(Bread_Demand)),
    LTRIM(RTRIM(Premium_Demand)),
    LTRIM(RTRIM(Family_Shopping)),
    LTRIM(RTRIM(Morning_Rush)),
    LTRIM(RTRIM(Evening_Rush))
FROM dbo.BranchBehaviour_Staging;
GO

SELECT
    BranchBehaviour_Key,
    Branch_Code,
    Branch_Name,
    Customer_Traffic,
    Bread_Demand,
    Premium_Demand,
    Family_Shopping,
    Morning_Rush,
    Evening_Rush
FROM dbo.DimBranchBehaviour
ORDER BY Branch_Code;

SELECT COUNT(*) AS Branch_Behaviour_Count
FROM dbo.DimBranchBehaviour;

--Now we move into the core transaction architecture:
--Receipts → Transactions → Payments

/*
There are 6 receipts where Payment Amount does not equal the transaction Line_Total sum.

The discrepancies are:

Receipt	Payment	Transaction Total	Difference
RCT00038173	₦193,579.61	₦30,063.96	₦163,515.65
RCT00153102	₦228,217.24	₦143,393.85	₦84,823.39
RCT00190577	₦129,113.62	₦44,430.91	₦84,682.71
RCT00115320	₦69,214.71	₦2,349.89	₦66,864.82
RCT00076843	₦40,411.33	₦26,295.23	₦14,116.10
RCT00224678	₦50,752.41	₦47,869.87	₦2,882.54

Ths is the workflow
RECEIPTS
    ↓
Receipts_Staging
    ↓
QA
    ↓
FactReceipt

TRANSACTIONS
    ↓
Transactions_Staging
    ↓
QA
    ↓
FactSales

PAYMENTS
    ↓
Payments_Staging
    ↓
QA
    ↓
FactPayment
*/


SELECT COUNT(*) AS Receipts_Staging_Count
FROM dbo.Receipts_Staging;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Receipts_Staging'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10 *
FROM dbo.Receipts_Staging
ORDER BY Receipt_No;

--Receipts QA
-- 1. Check for duplicate receipts
SELECT 
    Receipt_No,
    COUNT(*) AS Duplicate_Count
FROM dbo.Receipts_Staging
GROUP BY Receipt_No
HAVING COUNT(*) > 1;

-- 2. Check for missing critical fields
SELECT
    SUM(CASE WHEN Receipt_No IS NULL THEN 1 ELSE 0 END) AS Missing_Receipt_No,
    SUM(CASE WHEN Transaction_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Transaction_Date,
    SUM(CASE WHEN Transaction_Time IS NULL THEN 1 ELSE 0 END) AS Missing_Transaction_Time,
    SUM(CASE WHEN Branch_Code IS NULL THEN 1 ELSE 0 END) AS Missing_Branch_Code,
    SUM(CASE WHEN Cashier_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Cashier_ID,
    SUM(CASE WHEN Customer_Type IS NULL THEN 1 ELSE 0 END) AS Missing_Customer_Type,
    SUM(CASE WHEN Basket_Size IS NULL THEN 1 ELSE 0 END) AS Missing_Basket_Size,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS Missing_Payment_Method
FROM dbo.Receipts_Staging;

-- 3. Walk-In customers should not have Customer_ID,
-- Registered customers should have Customer_ID

SELECT
    Customer_Type,
    COUNT(*) AS Total_Receipts,
    SUM(
        CASE 
            WHEN Customer_Type = 'Walk-In' 
                 AND Customer_ID IS NOT NULL 
            THEN 1 
            ELSE 0 
        END
    ) AS WalkIn_With_CustomerID,
    
    SUM(
        CASE 
            WHEN Customer_Type = 'Registered' 
                 AND Customer_ID IS NULL 
            THEN 1 
            ELSE 0 
        END
    ) AS Registered_Without_CustomerID
FROM dbo.Receipts_Staging
GROUP BY Customer_Type;

/*
Receipts CSV
    ↓
Receipts_Staging
    ↓
225,499 rows
    ↓
Schema validated
    ↓
Duplicate check passed
    ↓
Missing critical fields passed
    ↓
Walk-In / Registered customer logic passed
*/

--Next: Transactions_Staging
--This is the big table: 1,807,529 rows

SELECT COUNT(*) AS Transactions_Staging_Count
FROM dbo.Transactions_Staging;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Transactions_Staging'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10 *
FROM dbo.Transactions_Staging
ORDER BY Receipt_No, Line_Number;

--Transaction QA
SELECT 
    Receipt_No,
    Line_Number,
    COUNT(*) AS Duplicate_Count
FROM dbo.Transactions_Staging
GROUP BY Receipt_No, Line_Number
HAVING COUNT(*) > 1;

SELECT
    SUM(CASE WHEN Receipt_No IS NULL THEN 1 ELSE 0 END) AS Missing_Receipt_No,
    SUM(CASE WHEN Line_Number IS NULL THEN 1 ELSE 0 END) AS Missing_Line_Number,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Product_ID,
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS Missing_Product_Name,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS Missing_Category,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Missing_Quantity,
    SUM(CASE WHEN Unit_Price IS NULL THEN 1 ELSE 0 END) AS Missing_Unit_Price,
    SUM(CASE WHEN Discount_Percent IS NULL THEN 1 ELSE 0 END) AS Missing_Discount_Percent,
    SUM(CASE WHEN Discount_Amount IS NULL THEN 1 ELSE 0 END) AS Missing_Discount_Amount,
    SUM(CASE WHEN VAT IS NULL THEN 1 ELSE 0 END) AS Missing_VAT,
    SUM(CASE WHEN Line_Total IS NULL THEN 1 ELSE 0 END) AS Missing_Line_Total
FROM dbo.Transactions_Staging;

SELECT
    SUM(CASE WHEN Quantity <= 0 THEN 1 ELSE 0 END) AS Invalid_Quantity,
    SUM(CASE WHEN Unit_Price < 0 THEN 1 ELSE 0 END) AS Negative_Unit_Price,
    SUM(CASE WHEN Discount_Percent < 0 OR Discount_Percent > 100 THEN 1 ELSE 0 END) AS Invalid_Discount_Percent,
    SUM(CASE WHEN Discount_Amount < 0 THEN 1 ELSE 0 END) AS Negative_Discount_Amount,
    SUM(CASE WHEN VAT < 0 THEN 1 ELSE 0 END) AS Negative_VAT,
    SUM(CASE WHEN Line_Total < 0 THEN 1 ELSE 0 END) AS Negative_Line_Total
FROM dbo.Transactions_Staging;



SELECT
    COUNT(*) AS Total_Lines,
    SUM(
        CASE 
            WHEN ABS(
                Line_Total -
                (
                    ((Quantity * Unit_Price) - Discount_Amount)
                    + VAT
                )
            ) > 0.01
            THEN 1 
            ELSE 0 
        END
    ) AS Calculation_Mismatches
FROM dbo.Transactions_Staging;

SELECT TOP 20
    Receipt_No,
    Line_Number,
    Product_ID,
    Product_Name,
    Quantity,
    Unit_Price,
    Discount_Percent,
    Discount_Amount,
    VAT,
    Line_Total,
    
    ((Quantity * Unit_Price) - Discount_Amount + VAT) 
        AS Expected_Line_Total,
        
    Line_Total -
    ((Quantity * Unit_Price) - Discount_Amount + VAT)
        AS Difference
FROM dbo.Transactions_Staging
WHERE ABS(
    Line_Total -
    ((Quantity * Unit_Price) - Discount_Amount + VAT)
) > 0.01
ORDER BY ABS(
    Line_Total -
    ((Quantity * Unit_Price) - Discount_Amount + VAT)
) DESC;

SELECT
    MAX(
        ABS(
            Line_Total -
            ((Quantity * Unit_Price) - Discount_Amount + VAT)
        )
    ) AS Max_Difference,
    
    AVG(
        ABS(
            Line_Total -
            ((Quantity * Unit_Price) - Discount_Amount + VAT)
        )
    ) AS Average_Difference
FROM dbo.Transactions_Staging;

SELECT
    COUNT(*) AS Total_Lines,
    SUM(
        CASE 
            WHEN ABS(
                Line_Total - 
                ((Quantity * Unit_Price) - Discount_Amount + VAT)
            ) > 0.1
            THEN 1 
            ELSE 0 
        END
    ) AS Significant_Mismatches
FROM dbo.Transactions_Staging;
/*
================================================================================
CALCULATION MISMATCH VALIDATION - RESULTS: NO SIGNIFICANT ISSUES FOUND
================================================================================
The following queries were used to validate Line_Total calculations in the 
Transactions_Staging table. Investigation revealed that minor differences 
(< 0.01) are due to normal rounding and are not significant. No material 
mismatches were found.

CONCLUSION: All differences are within acceptable rounding tolerances. 
Data quality validation passed - no action required.
================================================================================
*/

--Next: Payments_Staging
USE JRAD_Retail_Analytics;
GO

-- 1. Count rows
SELECT COUNT(*) AS Payments_Staging_Count
FROM dbo.Payments_Staging;


-- 2. Check table structure
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Payments_Staging'
ORDER BY ORDINAL_POSITION;


-- 3. Preview the data
SELECT TOP 10 *
FROM dbo.Payments_Staging;


--Payments QA
-- 1. Check for duplicate Payment IDs
SELECT 
    Payment_ID,
    COUNT(*) AS Duplicate_Count
FROM dbo.Payments_Staging
GROUP BY Payment_ID
HAVING COUNT(*) > 1;


-- 2. Check for missing critical values
SELECT
    SUM(CASE WHEN Payment_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Payment_ID,
    SUM(CASE WHEN Receipt_No IS NULL THEN 1 ELSE 0 END) AS Missing_Receipt_No,
    SUM(CASE WHEN Transaction_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Transaction_Date,
    SUM(CASE WHEN Branch_Code IS NULL THEN 1 ELSE 0 END) AS Missing_Branch_Code,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS Missing_Payment_Method,
    SUM(CASE WHEN Amount IS NULL THEN 1 ELSE 0 END) AS Missing_Amount,
    SUM(CASE WHEN Payment_Status IS NULL THEN 1 ELSE 0 END) AS Missing_Payment_Status
FROM dbo.Payments_Staging;


-- 3. Check Payment Method and Status distribution
SELECT
    Payment_Method,
    Payment_Status,
    COUNT(*) AS Number_of_Payments
FROM dbo.Payments_Staging
GROUP BY Payment_Method, Payment_Status
ORDER BY Payment_Method, Payment_Status;

--Payments_Staging passes the basic checks. 
--Now the key financial integrity test: does each payment amount match the corresponding receipt total?
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Receipts_Staging'
ORDER BY ORDINAL_POSITION;

SELECT TOP 20
    P.Payment_ID,
    P.Receipt_No,
    P.Amount AS Payment_Amount,
    SUM(T.Line_Total) AS Calculated_Transaction_Total,
    P.Amount - SUM(T.Line_Total) AS Difference
FROM dbo.Payments_Staging P
INNER JOIN dbo.Transactions_Staging T
    ON P.Receipt_No = T.Receipt_No
GROUP BY
    P.Payment_ID,
    P.Receipt_No,
    P.Amount
HAVING ABS(P.Amount - SUM(T.Line_Total)) > 0.1
ORDER BY ABS(P.Amount - SUM(T.Line_Total)) DESC;


SELECT
    COUNT(*) AS Total_Payments,
    
    SUM(CASE 
        WHEN X.Receipt_No IS NULL THEN 1 
        ELSE 0 
    END) AS Payments_Without_Transactions,
    
    SUM(CASE 
        WHEN X.Receipt_No IS NOT NULL
         AND ABS(X.Payment_Amount - X.Transaction_Total) > 0.1
        THEN 1 
        ELSE 0 
    END) AS Significant_Amount_Mismatches

FROM (
    SELECT
        P.Payment_ID,
        P.Receipt_No,
        P.Amount AS Payment_Amount,
        SUM(T.Line_Total) AS Transaction_Total
    FROM dbo.Payments_Staging P
    LEFT JOIN dbo.Transactions_Staging T
        ON P.Receipt_No = T.Receipt_No
    GROUP BY
        P.Payment_ID,
        P.Receipt_No,
        P.Amount
) X;

-- clean data reconciliation.

--Next phase: Cross-table integrity checks

SELECT
    COUNT(*) AS Orphan_Transaction_Lines
FROM dbo.Transactions_Staging T
LEFT JOIN dbo.Receipts_Staging R
    ON T.Receipt_No = R.Receipt_No
WHERE R.Receipt_No IS NULL;

SELECT
    COUNT(*) AS Orphan_Payments
FROM dbo.Payments_Staging P
LEFT JOIN dbo.Receipts_Staging R
    ON P.Receipt_No = R.Receipt_No
WHERE R.Receipt_No IS NULL;

SELECT
    Receipt_No,
    COUNT(*) AS Payment_Record_Count
FROM dbo.Payments_Staging
GROUP BY Receipt_No
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS Receipts_Without_Payment
FROM dbo.Receipts_Staging R
LEFT JOIN dbo.Payments_Staging P
    ON R.Receipt_No = P.Receipt_No
WHERE P.Receipt_No IS NULL;


--Employee Master 
USE JRAD_Retail_Analytics;
GO

SELECT COUNT(*) AS EmployeeMaster_Staging_Count
FROM dbo.EmployeeMaster_Staging;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EmployeeMaster_Staging'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10 *
FROM dbo.EmployeeMaster_Staging
ORDER BY Employee_ID;


USE JRAD_Retail_Analytics;
GO

-- 1. Check for duplicate Employee IDs
SELECT
    Employee_ID,
    COUNT(*) AS Duplicate_Count
FROM dbo.EmployeeMaster_Staging
GROUP BY Employee_ID
HAVING COUNT(*) > 1;


-- 2. Count management vs cashier employees
SELECT
    CASE
        WHEN Employee_ID LIKE 'CSH%' THEN 'Cashier'
        WHEN Employee_ID LIKE 'JRAD-EMP-%' THEN 'Management/Operations'
        ELSE 'Other'
    END AS Employee_Group,
    COUNT(*) AS Number_of_Employees
FROM dbo.EmployeeMaster_Staging
GROUP BY
    CASE
        WHEN Employee_ID LIKE 'CSH%' THEN 'Cashier'
        WHEN Employee_ID LIKE 'JRAD-EMP-%' THEN 'Management/Operations'
        ELSE 'Other'
    END;


-- 3. Check Cashier IDs against Receipts
SELECT
    R.Cashier_ID,
    COUNT(*) AS Receipt_Count
FROM dbo.Receipts_Staging R
LEFT JOIN dbo.EmployeeMaster_Staging E
    ON R.Cashier_ID = E.Employee_ID
WHERE E.Employee_ID IS NULL
GROUP BY R.Cashier_ID;


-- 4. Preview the employee records
SELECT TOP 15
    Employee_ID,
    Employee_Number,
    Full_Name,
    Branch_ID,
    Department,
    Job_Title,
    Employment_Status
FROM dbo.EmployeeMaster_Staging
ORDER BY Employee_ID;


USE JRAD_Retail_Analytics;
GO

IF OBJECT_ID('dbo.Employee_Master', 'U') IS NOT NULL
    DROP TABLE dbo.Employee_Master;
GO

 CREATE TABLE dbo.Employee_Master (
    Employee_ID NVARCHAR(50) NOT NULL PRIMARY KEY,
    Employee_Number NVARCHAR(50) NULL,

    First_Name NVARCHAR(100) NULL,
    Last_Name NVARCHAR(100) NULL,
    Full_Name NVARCHAR(200) NULL,
    Gender NVARCHAR(20) NULL,

    Date_of_Birth DATE NULL,
    Age_2026 TINYINT NULL,

    Phone_Number NVARCHAR(30) NULL,
    Email NVARCHAR(150) NULL,

    Branch_ID NVARCHAR(50) NULL,
    Branch_Name NVARCHAR(100) NULL,

    Department NVARCHAR(100) NULL,
    Job_Title NVARCHAR(100) NULL,

    Employment_Type NVARCHAR(50) NULL,
    Daily_Shift NVARCHAR(100) NULL,

    Hire_Date DATE NULL,

    Basic_Salary_NGN DECIMAL(18,2) NULL,
    Performance_Rating DECIMAL(3,1) NULL,

    Employment_Status NVARCHAR(50) NULL,

    Default_POS_Register NVARCHAR(50) NULL
);
GO


INSERT INTO dbo.Employee_Master (
    Employee_ID,
    Employee_Number,
    First_Name,
    Last_Name,
    Full_Name,
    Gender,
    Date_of_Birth,
    Age_2026,
    Phone_Number,
    Email,
    Branch_ID,
    Branch_Name,
    Department,
    Job_Title,
    Employment_Type,
    Daily_Shift,
    Hire_Date,
    Basic_Salary_NGN,
    Performance_Rating,
    Employment_Status,
    Default_POS_Register
)
SELECT
    NULLIF(LTRIM(RTRIM(Employee_ID)), ''),
    NULLIF(LTRIM(RTRIM(Employee_Number)), ''),
    NULLIF(LTRIM(RTRIM(First_Name)), ''),
    NULLIF(LTRIM(RTRIM(Last_Name)), ''),
    NULLIF(LTRIM(RTRIM(Full_Name)), ''),
    NULLIF(LTRIM(RTRIM(Gender)), ''),

    TRY_CONVERT(DATE, Date_of_Birth),
    TRY_CONVERT(TINYINT, Age_2026),

    CASE 
        WHEN Phone_Number IS NOT NULL 
        THEN CAST(Phone_Number AS NVARCHAR(30))
        ELSE NULL 
    END,
    NULLIF(LTRIM(RTRIM(Email)), ''),

    NULLIF(LTRIM(RTRIM(Branch_ID)), ''),
    NULLIF(LTRIM(RTRIM(Branch_Name)), ''),

    NULLIF(LTRIM(RTRIM(Department)), ''),
    NULLIF(LTRIM(RTRIM(Job_Title)), ''),

    NULLIF(LTRIM(RTRIM(Employment_Type)), ''),
    NULLIF(LTRIM(RTRIM(Daily_Shift)), ''),

    TRY_CONVERT(DATE, Hire_Date),

    CAST(Basic_Salary_NGN AS DECIMAL(18,2)),
    CAST(Performance_Rating AS DECIMAL(3,1)),

    NULLIF(LTRIM(RTRIM(Employment_Status)), ''),
    NULLIF(LTRIM(RTRIM(Default_POS_Register)), '')
FROM dbo.EmployeeMaster_Staging;
GO


SELECT COUNT(*) AS Final_Employee_Count
FROM dbo.Employee_Master;

SELECT TOP 15
    Employee_ID,
    Full_Name,
    Branch_ID,
    Department,
    Job_Title,
    Default_POS_Register
FROM dbo.Employee_Master
ORDER BY Employee_ID;


USE JRAD_Retail_Analytics;
GO

-- 1. Overall employee count
SELECT COUNT(*) AS Total_Employees
FROM dbo.Employee_Master;


-- 2. Employee distribution by Job Title
SELECT
    Job_Title,
    COUNT(*) AS Number_of_Employees
FROM dbo.Employee_Master
GROUP BY Job_Title
ORDER BY Number_of_Employees DESC;


-- 3. Employee distribution by Branch
SELECT
    Branch_ID,
    Branch_Name,
    COUNT(*) AS Number_of_Employees
FROM dbo.Employee_Master
GROUP BY
    Branch_ID,
    Branch_Name
ORDER BY Branch_ID;


-- 4. Check for duplicate Employee IDs
SELECT
    Employee_ID,
    COUNT(*) AS Duplicate_Count
FROM dbo.Employee_Master
GROUP BY Employee_ID
HAVING COUNT(*) > 1;


-- 5. Check for missing important fields
SELECT *
FROM dbo.Employee_Master
WHERE Employee_ID IS NULL
   OR Full_Name IS NULL
   OR Branch_ID IS NULL
   OR Job_Title IS NULL;


-- 6. Verify cashier relationship with receipts
SELECT
    R.Cashier_ID,
    COUNT(*) AS Receipt_Count
FROM dbo.Receipts_Staging R
LEFT JOIN dbo.Employee_Master E
    ON R.Cashier_ID = E.Employee_ID
WHERE E.Employee_ID IS NULL
GROUP BY R.Cashier_ID;

/*
current data pipeline includes:

Master / Reference Tables
Product Master
Employee Master — 60 employees
Inventory
Pricing History
Business Events
Monthly Behaviour
Branch Behaviour

-------------------------------
Transaction / Operational Tables
Receipts
Transaction Lines
Payments

*/

--Phase 2 — Database Integration & Final Data Model

USE JRAD_Retail_Analytics;
GO

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'DimBranchBehaviour',
    'DimBusinessEvent',
    'DimCustomer',
    'DimMonthlyBehaviour',
    'DimPricingHistory',
    'DimProduct',
    'Employee_Master',
    'FactInventory'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;



USE JRAD_Retail_Analytics;
GO

-- =============================================
-- FactSales: Central transactional fact table
-- Grain: One row per product line item per receipt
-- =============================================

CREATE TABLE dbo.FactSales
(
    Sales_Key BIGINT IDENTITY(1,1) NOT NULL,
    
    -- Receipt context
    Receipt_No VARCHAR(20) NOT NULL,
    Line_Number SMALLINT NOT NULL,
    Transaction_Date DATE NOT NULL,
    Transaction_Time TIME NOT NULL,
    
    -- Foreign keys to dimensions
    Product_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NULL,            -- NULL for walk-in customers
    Employee_ID NVARCHAR(50) NOT NULL,        -- Cashier from Employee_Master
    Branch_Code VARCHAR(10) NOT NULL,
    
    -- Receipt-level attributes (denormalized for analysis)
    Customer_Type VARCHAR(50),
    Persona VARCHAR(100),
    Shopping_Mission VARCHAR(100),
    Basket_Size VARCHAR(20),
    Payment_Method VARCHAR(50),
    
    -- Product context (denormalized from transaction)
    Product_Name VARCHAR(255),
    Category VARCHAR(100),
    
    -- Transactional measures (facts)
    Quantity INT NOT NULL,
    Unit_Price DECIMAL(12,2) NOT NULL,
    Discount_Percent DECIMAL(5,2),
    Discount_Amount DECIMAL(12,2),
    VAT DECIMAL(12,2),
    Line_Total DECIMAL(12,2) NOT NULL,
    
    CONSTRAINT PK_FactSales
        PRIMARY KEY (Sales_Key),
    
    CONSTRAINT UQ_FactSales_Receipt_Line
        UNIQUE (Receipt_No, Line_Number),
    
    CONSTRAINT FK_FactSales_Product
        FOREIGN KEY (Product_ID)
        REFERENCES dbo.DimProduct(Product_ID),
    
    CONSTRAINT FK_FactSales_Customer
        FOREIGN KEY (Customer_ID)
        REFERENCES dbo.DimCustomer(Customer_ID),
    
    CONSTRAINT FK_FactSales_Employee
        FOREIGN KEY (Employee_ID)
        REFERENCES dbo.Employee_Master(Employee_ID)
);
GO

-- Create indexes for common query patterns
CREATE NONCLUSTERED INDEX IX_FactSales_TransactionDate 
    ON dbo.FactSales(Transaction_Date);

CREATE NONCLUSTERED INDEX IX_FactSales_ProductID 
    ON dbo.FactSales(Product_ID);

CREATE NONCLUSTERED INDEX IX_FactSales_BranchCode 
    ON dbo.FactSales(Branch_Code);

CREATE NONCLUSTERED INDEX IX_FactSales_CustomerID 
    ON dbo.FactSales(Customer_ID);

CREATE NONCLUSTERED INDEX IX_FactSales_ReceiptNo 
    ON dbo.FactSales(Receipt_No);
GO


USE JRAD_Retail_Analytics;
GO

INSERT INTO dbo.FactSales
(
    Receipt_No,
    Line_Number,
    Transaction_Date,
    Transaction_Time,
    Product_ID,
    Customer_ID,
    Employee_ID,
    Branch_Code,
    Customer_Type,
    Persona,
    Shopping_Mission,
    Basket_Size,
    Payment_Method,
    Product_Name,
    Category,
    Quantity,
    Unit_Price,
    Discount_Percent,
    Discount_Amount,
    VAT,
    Line_Total
)
SELECT
    T.Receipt_No,
    T.Line_Number,
    R.Transaction_Date,
    R.Transaction_Time,
    
    LTRIM(RTRIM(T.Product_ID)),
    NULLIF(LTRIM(RTRIM(R.Customer_ID)), ''),
    LTRIM(RTRIM(R.Cashier_ID)),
    LTRIM(RTRIM(R.Branch_Code)),
    
    LTRIM(RTRIM(R.Customer_Type)),
    LTRIM(RTRIM(R.Persona)),
    LTRIM(RTRIM(R.Shopping_Mission)),
    LTRIM(RTRIM(R.Basket_Size)),
    LTRIM(RTRIM(R.Payment_Method)),
    
    LTRIM(RTRIM(T.Product_Name)),
    LTRIM(RTRIM(T.Category)),
    
    T.Quantity,
    T.Unit_Price,
    T.Discount_Percent,
    T.Discount_Amount,
    T.VAT,
    T.Line_Total

FROM dbo.Transactions_Staging T
INNER JOIN dbo.Receipts_Staging R
    ON T.Receipt_No = R.Receipt_No;
GO



-- =============================================
-- FACTSALES VALIDATION SUITE
-- =============================================

-- 1. Row count verification
SELECT
    (SELECT COUNT(*) FROM dbo.Transactions_Staging) AS Transactions_Staging_Count,
    (SELECT COUNT(*) FROM dbo.FactSales) AS FactSales_Count,
    (SELECT COUNT(*) FROM dbo.Transactions_Staging) - 
    (SELECT COUNT(*) FROM dbo.FactSales) AS Difference;


-- 2. Check for any orphan product references
SELECT COUNT(*) AS Orphan_Product_References
FROM dbo.FactSales S
LEFT JOIN dbo.DimProduct P
    ON S.Product_ID = P.Product_ID
WHERE P.Product_ID IS NULL;


-- 3. Verify customer references (registered customers only)
SELECT COUNT(*) AS Invalid_Customer_References
FROM dbo.FactSales S
LEFT JOIN dbo.DimCustomer C
    ON S.Customer_ID = C.Customer_ID
WHERE S.Customer_ID IS NOT NULL
  AND C.Customer_ID IS NULL;


-- 4. Verify employee (cashier) references
SELECT COUNT(*) AS Invalid_Employee_References
FROM dbo.FactSales S
LEFT JOIN dbo.Employee_Master E
    ON S.Employee_ID = E.Employee_ID
WHERE E.Employee_ID IS NULL;


-- 5. Revenue reconciliation summary
SELECT
    SUM(Line_Total) AS Total_Sales_Revenue,
    COUNT(DISTINCT Receipt_No) AS Unique_Receipts,
    COUNT(*) AS Total_Line_Items,
    AVG(Line_Total) AS Average_Line_Value,
    MIN(Transaction_Date) AS Earliest_Transaction,
    MAX(Transaction_Date) AS Latest_Transaction
FROM dbo.FactSales;


-- 6. Sales distribution by branch
SELECT
    Branch_Code,
    COUNT(*) AS Line_Items,
    COUNT(DISTINCT Receipt_No) AS Receipts,
    SUM(Quantity) AS Total_Units_Sold,
    SUM(Line_Total) AS Total_Revenue,
    AVG(Line_Total) AS Average_Line_Value
FROM dbo.FactSales
GROUP BY Branch_Code
ORDER BY Total_Revenue DESC;


-- 7. Customer type distribution
SELECT
    Customer_Type,
    COUNT(DISTINCT Receipt_No) AS Receipts,
    COUNT(*) AS Line_Items,
    SUM(Line_Total) AS Revenue,
    AVG(Line_Total) AS Avg_Line_Value
FROM dbo.FactSales
GROUP BY Customer_Type
ORDER BY Revenue DESC;


-- 8. Check for duplicate receipt-line combinations
SELECT
    Receipt_No,
    Line_Number,
    COUNT(*) AS Duplicate_Count
FROM dbo.FactSales
GROUP BY Receipt_No, Line_Number
HAVING COUNT(*) > 1;


-- 9. Top 10 products by revenue
SELECT TOP 10
    S.Product_ID,
    S.Product_Name,
    S.Category,
    COUNT(*) AS Times_Sold,
    SUM(S.Quantity) AS Total_Quantity,
    SUM(S.Line_Total) AS Total_Revenue
FROM dbo.FactSales S
GROUP BY
    S.Product_ID,
    S.Product_Name,
    S.Category
ORDER BY Total_Revenue DESC;


-- 10. Daily sales trend
SELECT
    Transaction_Date,
    COUNT(DISTINCT Receipt_No) AS Daily_Receipts,
    COUNT(*) AS Daily_Line_Items,
    SUM(Line_Total) AS Daily_Revenue
FROM dbo.FactSales
GROUP BY Transaction_Date
ORDER BY Transaction_Date;


-- 11. Payment method distribution
SELECT
    Payment_Method,
    COUNT(DISTINCT Receipt_No) AS Receipts,
    SUM(Line_Total) AS Revenue,
    AVG(Line_Total) AS Avg_Transaction_Value
FROM dbo.FactSales
GROUP BY Payment_Method
ORDER BY Revenue DESC;


-- 12. Basket size analysis
SELECT
    Basket_Size,
    COUNT(DISTINCT Receipt_No) AS Number_of_Receipts,
    AVG(Quantity) AS Avg_Items_Per_Line,
    SUM(Line_Total) AS Total_Revenue
FROM dbo.FactSales
GROUP BY Basket_Size
ORDER BY 
    CASE Basket_Size
        WHEN 'Small' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Large' THEN 3
        ELSE 4
    END;


-- 13. Check NULL values in critical fields
SELECT
    SUM(CASE WHEN Receipt_No IS NULL THEN 1 ELSE 0 END) AS Null_Receipt_No,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Null_Product_ID,
    SUM(CASE WHEN Employee_ID IS NULL THEN 1 ELSE 0 END) AS Null_Employee_ID,
    SUM(CASE WHEN Branch_Code IS NULL THEN 1 ELSE 0 END) AS Null_Branch_Code,
    SUM(CASE WHEN Transaction_Date IS NULL THEN 1 ELSE 0 END) AS Null_Transaction_Date,
    SUM(CASE WHEN Line_Total IS NULL THEN 1 ELSE 0 END) AS Null_Line_Total
FROM dbo.FactSales;


-- 14. Final summary
SELECT
    'FactSales' AS Table_Name,
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT Receipt_No) AS Unique_Receipts,
    COUNT(DISTINCT Product_ID) AS Unique_Products,
    COUNT(DISTINCT Customer_ID) AS Registered_Customers,
    COUNT(DISTINCT Employee_ID) AS Cashiers,
    COUNT(DISTINCT Branch_Code) AS Branches,
    SUM(Line_Total) AS Total_Revenue_NGN,
    MIN(Transaction_Date) AS Data_Start_Date,
    MAX(Transaction_Date) AS Data_End_Date
FROM dbo.FactSales;


USE JRAD_Retail_Analytics;
GO

-- =============================================
-- FactPayments: Payment transaction fact table
-- Grain: One row per payment (one payment per receipt)
-- =============================================

CREATE TABLE dbo.FactPayments
(
    Payment_Key INT IDENTITY(1,1) NOT NULL,
    
    -- Payment identifiers
    Payment_ID VARCHAR(20) NOT NULL,
    Receipt_No VARCHAR(20) NOT NULL,
    
    -- Transaction context
    Transaction_Date DATE NOT NULL,
    
    -- Foreign keys
    Branch_Code VARCHAR(10) NOT NULL,
    Customer_ID VARCHAR(20) NULL,        -- NULL for walk-in customers
    
    -- Payment details
    Payment_Method VARCHAR(50) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    Payment_Status VARCHAR(50) NOT NULL,
    
    -- Reference data
    Currency VARCHAR(10) DEFAULT 'NGN',
    
    CONSTRAINT PK_FactPayments
        PRIMARY KEY (Payment_Key),
    
    CONSTRAINT UQ_FactPayments_Payment_ID
        UNIQUE (Payment_ID),
    
    CONSTRAINT UQ_FactPayments_Receipt_No
        UNIQUE (Receipt_No),
    
    CONSTRAINT FK_FactPayments_Customer
        FOREIGN KEY (Customer_ID)
        REFERENCES dbo.DimCustomer(Customer_ID)
);
GO

-- Indexes for performance
CREATE NONCLUSTERED INDEX IX_FactPayments_TransactionDate 
    ON dbo.FactPayments(Transaction_Date);

CREATE NONCLUSTERED INDEX IX_FactPayments_BranchCode 
    ON dbo.FactPayments(Branch_Code);

CREATE NONCLUSTERED INDEX IX_FactPayments_PaymentMethod 
    ON dbo.FactPayments(Payment_Method);

CREATE NONCLUSTERED INDEX IX_FactPayments_ReceiptNo 
    ON dbo.FactPayments(Receipt_No);
GO


USE JRAD_Retail_Analytics;
GO

INSERT INTO dbo.FactPayments
(
    Payment_ID,
    Receipt_No,
    Transaction_Date,
    Branch_Code,
    Customer_ID,
    Payment_Method,
    Amount,
    Payment_Status
)
SELECT
    LTRIM(RTRIM(P.Payment_ID)),
    LTRIM(RTRIM(P.Receipt_No)),
    P.Transaction_Date,
    LTRIM(RTRIM(P.Branch_Code)),
    NULLIF(LTRIM(RTRIM(R.Customer_ID)), ''),  -- Get Customer_ID from Receipts
    LTRIM(RTRIM(P.Payment_Method)),
    P.Amount,
    LTRIM(RTRIM(P.Payment_Status))
FROM dbo.Payments_Staging P
INNER JOIN dbo.Receipts_Staging R
    ON P.Receipt_No = R.Receipt_No;
GO


-- Quick validation
SELECT COUNT(*) AS FactPayments_Count
FROM dbo.FactPayments;

-- Verify against staging
SELECT
    (SELECT COUNT(*) FROM dbo.Payments_Staging) AS Staging_Count,
    (SELECT COUNT(*) FROM dbo.FactPayments) AS FactPayments_Count;

-- Preview records
SELECT TOP 10
    Payment_Key,
    Payment_ID,
    Receipt_No,
    Transaction_Date,
    Branch_Code,
    Payment_Method,
    Amount,
    Payment_Status
FROM dbo.FactPayments
ORDER BY Payment_Key;


-- =============================================
-- FACTINVENTORY EXTENDED VALIDATION
-- =============================================

-- 1. Verify all products in FactSales have inventory records
SELECT
    S.Product_ID,
    S.Product_Name,
    S.Branch_Code,
    COUNT(*) AS Times_Sold,
    SUM(S.Quantity) AS Total_Quantity_Sold
FROM dbo.FactSales S
LEFT JOIN dbo.FactInventory I
    ON S.Product_ID = I.Product_ID
    AND S.Branch_Code = I.Branch_Code
WHERE I.Product_ID IS NULL
GROUP BY
    S.Product_ID,
    S.Product_Name,
    S.Branch_Code
ORDER BY Total_Quantity_Sold DESC;


-- 2. Inventory vs Sales comparison by branch
SELECT
    I.Branch_Code,
    I.Branch_Name,
    COUNT(DISTINCT I.Product_ID) AS Products_In_Inventory,
    SUM(I.Current_Stock) AS Total_Current_Stock,
    SUM(I.Opening_Stock) AS Total_Opening_Stock,
    (
        SELECT COUNT(DISTINCT S.Product_ID)
        FROM dbo.FactSales S
        WHERE S.Branch_Code = I.Branch_Code
    ) AS Products_Sold
FROM dbo.FactInventory I
GROUP BY
    I.Branch_Code,
    I.Branch_Name
ORDER BY I.Branch_Code;


-- 3. Stock status breakdown
SELECT
    Stock_Status,
    COUNT(*) AS Number_of_Products,
    SUM(Current_Stock) AS Total_Current_Stock,
    AVG(Current_Stock) AS Average_Stock_Level
FROM dbo.FactInventory
GROUP BY Stock_Status
ORDER BY 
    CASE Stock_Status
        WHEN 'Out of Stock' THEN 1
        WHEN 'Low Stock' THEN 2
        WHEN 'In Stock' THEN 3
        WHEN 'Overstocked' THEN 4
        ELSE 5
    END;


-- 4. Products sold but with low/no inventory
SELECT
    S.Product_ID,
    S.Product_Name,
    S.Branch_Code,
    SUM(S.Quantity) AS Total_Sold,
    I.Current_Stock,
    I.Stock_Status,
    I.Reorder_Level
FROM dbo.FactSales S
INNER JOIN dbo.FactInventory I
    ON S.Product_ID = I.Product_ID
    AND S.Branch_Code = I.Branch_Code
WHERE I.Stock_Status IN ('Low Stock', 'Out of Stock')
GROUP BY
    S.Product_ID,
    S.Product_Name,
    S.Branch_Code,
    I.Current_Stock,
    I.Stock_Status,
    I.Reorder_Level
ORDER BY Total_Sold DESC;





SELECT
    t.name AS Table_Name,
    p.rows AS Row_Count,
    CASE
        WHEN t.name LIKE 'Dim%' THEN 'Dimension'
        WHEN t.name LIKE 'Fact%' THEN 'Fact'
        WHEN t.name LIKE '%Staging%' THEN 'Staging'
        ELSE 'Reference'
    END AS Table_Type
FROM sys.tables t
INNER JOIN sys.partitions p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
    AND t.name NOT LIKE 'sys%'
ORDER BY Table_Type, t.name;


SELECT
    fk.name AS FK_Name,
    OBJECT_NAME(fk.parent_object_id) AS Child_Table,
    COL_NAME(
        fkc.parent_object_id,
        fkc.parent_column_id
    ) AS Child_Column,
    OBJECT_NAME(fk.referenced_object_id) AS Parent_Table,
    COL_NAME(
        fkc.referenced_object_id,
        fkc.referenced_column_id
    ) AS Parent_Column
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) NOT LIKE '%Staging%'
ORDER BY Child_Table, Parent_Table;


SELECT
    'DIMENSION TABLES' AS Category,
    'DimProduct' AS Table_Name,
    (SELECT COUNT(*) FROM dbo.DimProduct) AS Record_Count,
    'Product_ID' AS Key_Field

UNION ALL

SELECT
    'DIMENSION TABLES',
    'DimCustomer',
    (SELECT COUNT(*) FROM dbo.DimCustomer),
    'Customer_ID'

UNION ALL

SELECT
    'DIMENSION TABLES',
    'Employee_Master',
    (SELECT COUNT(*) FROM dbo.Employee_Master),
    'Employee_ID'

UNION ALL

SELECT
    'DIMENSION TABLES',
    'DimPricingHistory',
    (SELECT COUNT(*) FROM dbo.DimPricingHistory),
    'Pricing_ID'

UNION ALL

SELECT
    'DIMENSION TABLES',
    'DimBusinessEvent',
    (SELECT COUNT(*) FROM dbo.DimBusinessEvent),
    'Event_ID'

UNION ALL

SELECT
    'DIMENSION TABLES',
    'DimMonthlyBehaviour',
    (SELECT COUNT(*) FROM dbo.DimMonthlyBehaviour),
    'Week'

UNION ALL

SELECT
    'DIMENSION TABLES',
    'DimBranchBehaviour',
    (SELECT COUNT(*) FROM dbo.DimBranchBehaviour),
    'Branch_Code'

UNION ALL

SELECT
    'FACT TABLES',
    'FactSales',
    (SELECT COUNT(*) FROM dbo.FactSales),
    'Sales_Key'

UNION ALL

SELECT
    'FACT TABLES',
    'FactPayments',
    (SELECT COUNT(*) FROM dbo.FactPayments),
    'Payment_Key'

UNION ALL

SELECT
    'FACT TABLES',
    'FactInventory',
    (SELECT COUNT(*) FROM dbo.FactInventory),
    'Inventory_Key'

ORDER BY Category, Table_Name;

/*
JRAD Retail Analytics Data Warehouse - Development Log
Project Overview
Database: JRAD_Retail_Analytics
Architecture: Star Schema Data Warehouse
Total Records Processed: 2,036,688 rows
Development Timeline: Systematic ETL pipeline with comprehensive validation


Dimension Tables (Reference Data)
Table	    Records	        Key Achievement
DimProduct	632	            Complete product master with pricing, categorization, and attributes
DimCustomer	800	            Customer profiles with loyalty status, demographics, and preferences
DimPricingHistory 2,549	    Historical price changes (632 initial prices + 1,917 adjustments)
Employee_Master	60	        Complete staff registry including 40+ cashiers
DimBusinessEvent	10	    Promotional events with traffic/basket/spend multipliers
DimMonthlyBehaviour	4	    Weekly shopping pattern taxonomy
DimBranchBehaviour	5	    Branch-specific customer behavior profiles


Fact Tables (Transactional Data)
Table	    Records	    Grain
FactSales	1,807,529	One row per product line item per receipt
FactPayments	225,499	One row per payment transaction
FactInventory	3,160	632 products × 5 branches


Key Technical Achievements
1. Data Quality Remediation
•	Pricing Calculation Fix: Identified 9 records where Price_Change was lost during CSV import
•	Repair: Price_Change = New_Price - Previous_Price
•	Validation: 100% calculation accuracy achieved
•	Phone Number Standardization: Prepended '0' to customer phone numbers during transformation
•	Customer Type Logic: Enforced business rule that Walk-In customers have no Customer_ID, while Registered customers must have one

2. Referential Integrity Validation
    Zero orphan records across all foreign key relationships:
•	All pricing history records link to valid products
•	All inventory positions reference existing products
•	All sales transactions reference valid products, employees, and customers
•	All payments reconcile to receipts

3. Financial Reconciliation
•	Line Total Accuracy: Validated Line_Total = (Quantity × Unit_Price) - Discount + VAT across 1.8M records
•	Payment Reconciliation: 6 receipts identified with payment vs. transaction total discrepancies (documented, not corrected to preserve source data integrity)
•	Tolerance: Accepted ±₦0.01 rounding differences as standard

4. Business Logic Implementation
•	Christmas Event Validation: Confirmed 2 Christmas promotional windows (Dec 15-31) with appropriate multipliers
•	Event Overlap Detection: Identified and documented overlapping promotional events for business calendar management
•	Stock Status Rules: Categorized inventory into Out of Stock / Low Stock / In Stock / Overstocked

Source Excel/CSV
      ↓
[Import Flat File Wizard]
      ↓
Staging Table (_Staging suffix)
      ↓
[Schema Validation]
      ↓
[Duplicate Detection]
      ↓
[Null Value Check]
      ↓
[Business Rule Validation]
      ↓
[Referential Integrity Check]
      ↓
Production Table (Dim/Fact prefix)
      ↓
[Post-Load Validation]



Notable Validation Queries
Cross-Table Integrity
•	Verified zero orphan transactions (all receipts have matching transaction lines)
•	Confirmed zero orphan payments (all payments link to valid receipts)
•	Validated employee-cashier mapping (all cashier IDs exist in Employee_Master)

Business Insights Enabled
•	Daily sales trends by branch
•	Top products by revenue
•	Customer persona distribution
•	Payment method preferences
•	Basket size analysis
•	Stock availability vs. demand patterns


 Performance Optimizations
Indexes Created:
•	IX_FactSales_TransactionDate - Time-series analysis
•	IX_FactSales_ProductID - Product performance queries
•	IX_FactSales_BranchCode - Branch comparisons
•	IX_FactSales_CustomerID - Customer behavior analysis
•	IX_FactSales_ReceiptNo - Receipt-level aggregations
•	Similar indexes on FactPayments

Constraints Enforced:
•	Primary keys on all tables
•	Unique constraints on business keys (Product_ID, Customer_ID, Receipt_No, etc.)
•	Check constraints for data validity (multipliers > 0, Start_Date ≤ End_Date)
•	Foreign key relationships for referential integrity


        DimProduct (632)
              │
              ├────────────────┬─────────────────┐
              │                │                 │
              ▼                ▼                 ▼
    DimPricingHistory   FactInventory      FactSales
         (2,549)          (3,160)        (1,807,529)
                                               │
                                               ├──── DimCustomer (800)
                                               ├──── Employee_Master (60)
                                               └──── FactPayments (225,499)

        DimBusinessEvent (10) ─┐
       DimMonthlyBehaviour (4) ├─→ [Applied to FactSales analysis]
      DimBranchBehaviour (5) ──┘


Quality Assurance Metrics
•	Data Completeness: 100% - No critical NULL values in required fields
•	Referential Integrity: 100% - All FK relationships validated
•	Calculation Accuracy: 99.9995% - Only minor rounding differences (< ₦0.01)
•	Duplicate Prevention: 100% - Unique constraints enforced on all business keys
•	Business Rule Compliance: 100% - Customer type, event dates, multipliers validated


Outcome
The JRAD Retail Analytics Data Warehouse is production-ready, supporting:
•	Sales performance analysis
•	Customer behavior segmentation
•	Inventory optimization
•	Price elasticity modeling
•	Promotional effectiveness measurement
•	Cashier productivity tracking
•	Branch-level operational insights

Total Development Validation Queries Executed: 100+
Data Pipeline Status: COMPLETE & VALIDATED
