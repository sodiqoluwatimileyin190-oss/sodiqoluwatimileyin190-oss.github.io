# Inside the Retail Engine: SQL Data Modeling & Business Analysis

> **Project Disclaimer**
>
> JRAD Retail is a fictional and simulated retail environment created for portfolio and analytical purposes. The project is not affiliated with, endorsed by, or based on proprietary data from any real retailer.
>
> The analysis in this project was performed using the simulated JRAD Retail Data System developed from custom business rules, behavioural logic, probability distributions, and transaction-generation processes.

---

# Project Overview

After building the JRAD Retail Data System and generating large-scale transactional data, the next stage of the project focused on transforming the generated data into a structured relational environment for validation and business analysis.

This project uses SQL to explore the internal operations of the retail system, covering sales transactions, customers, products, branches, payments, inventory, and operational performance.

The analysis was performed on a retail dataset containing more than **1.8 million transaction lines**, generated across five simulated retail branches.

Rather than simply querying isolated tables, the project involved validating relationships between datasets, building analytical structures, checking data quality, and investigating business patterns across the retail ecosystem.

---

# Project Objective

The objective of this project was to use SQL to transform a large-scale simulated retail dataset into meaningful business intelligence.

The analysis focused on answering questions such as:

- How large is the retail data environment?
- Are the relationships between the datasets valid?
- Are there duplicate or orphan records?
- How does sales performance vary across branches?
- Which products and categories drive demand?
- How do customers and payment methods behave?
- What patterns exist within transaction and basket behaviour?
- Where are potential inventory and stock-out risks?
- What operational and revenue opportunities can be identified from the data?

---

# Dataset Scale

The SQL environment was built around a large interconnected retail dataset containing:

- **1,807,529 transaction lines**
- **225,499 receipts**
- **225,499 payment records**
- **525 products**
- **5 retail branches**
- **800 registered customers**
- **40 cashier or employee records**

The scale of the dataset allowed the project to move beyond simple sample-data analysis and work with a more realistic volume of interconnected retail activity.

---

# Data Architecture and SQL Environment

The JRAD Retail system consists of multiple interconnected datasets representing different parts of retail operations.

Key entities include:

- Customers
- Products
- Branches
- Sales transactions
- Payments
- Receipts
- Employees and cashiers
- Inventory
- Business events
- Customer experience
- Queue and operational metrics
- Product pricing history

These datasets were loaded into SQL and used to create a structured environment for validation and analysis.

---

# Building the Analytical Foundation

Before performing business analysis, the data environment was examined to understand the relationships between the different datasets.

The analysis involved working with transactional and dimensional data to establish connections between:

- Customers and transactions
- Products and sales activity
- Branches and operational performance
- Receipts and payments
- Cashiers and transactions
- Inventory and product availability

A central sales structure was then used to support analysis across multiple areas of the business.

---

# Data Validation and Quality Checks

Data validation was an important stage of the SQL analysis.

The project included checks for:

- Duplicate records
- Orphan records
- Referential integrity
- Missing relationships between tables
- Receipt and payment consistency
- Transaction-level validation
- Revenue reconciliation

These checks helped confirm that the simulated datasets could be reliably connected for downstream analysis.

---

# Sales and Revenue Analysis

SQL was used to investigate overall sales activity and revenue performance across the retail environment.

The analysis explored:

- Total transaction activity
- Revenue patterns
- Daily sales performance
- Branch-level performance
- Product demand
- Customer purchasing behaviour
- Basket and transaction patterns

This stage helped identify where commercial activity was concentrated and how performance varied across the retail system.

---

# Customer and Payment Analysis

The customer and payment datasets were used to explore purchasing behaviour and transaction preferences.

Areas investigated included:

- Customer transaction behaviour
- Registered and unregistered customer activity
- Payment method distribution
- Receipt-level purchasing patterns
- Basket size behaviour
- Customer contribution to retail activity

The analysis supports a broader understanding of how customers interact with the retail environment.

---

# Product and Branch Performance

Product and branch analysis was performed to investigate differences in demand and commercial performance.

The analysis included:

- Product-level sales activity
- High-demand products
- Branch performance
- Revenue contribution
- Differences in transaction volume
- Product availability patterns

These insights can support decisions around inventory allocation, branch operations, and product planning.

---

# Inventory and Stock Analysis

Inventory analysis was used to classify product availability into operational categories such as:

- In Stock
- Low Stock
- Out of Stock

This analysis helps identify potential stock risks and highlights areas where product availability may affect customer experience and potential revenue.

Stock availability is particularly important in a retail environment because unavailable high-demand products may lead to:

- Substituted purchases
- Delayed purchases
- Customer dissatisfaction
- Lost sales

---

# SQL Analysis Workflow

The project followed the following workflow:

1. Loaded the JRAD Retail datasets into SQL.
2. Examined the structure and scale of the data.
3. Investigated relationships between datasets.
4. Performed data quality and validation checks.
5. Validated transactional, receipt, and payment relationships.
6. Built the analytical foundation for sales analysis.
7. Analyzed customer behaviour and payment patterns.
8. Investigated product and branch performance.
9. Examined transaction and basket behaviour.
10. Performed inventory and stock availability analysis.
11. Identified business opportunities and operational risks.

---

# Key Skills Demonstrated

- SQL querying
- Relational data analysis
- Data validation
- Data quality assessment
- Referential integrity checks
- Data modeling
- Fact and dimensional analysis
- JOINs
- Common Table Expressions (CTEs)
- Aggregations
- Window functions
- Revenue analysis
- Customer analysis
- Product performance analysis
- Branch performance analysis
- Inventory analysis

---

# Tools Used

- SQL
- Microsoft SQL Server
- Microsoft Excel
- Python
- Power BI

---

# Project Outcome

This project demonstrates the stage between large-scale data generation and business intelligence reporting.

The JRAD Retail Data System created the simulated retail environment.

This SQL project moves inside that environment to validate the data, investigate relationships, and uncover business patterns across more than **1.8 million transaction lines**.

The resulting analytical foundation supports the next stage of the project:

## Advanced Business Intelligence and Dashboard Development

The validated and analyzed data will be used to build advanced Power BI dashboards focused on:

- Executive performance
- Branch operations
- Customer behaviour
- Loyalty and retention
- Product demand
- Inventory and stock-out risks
- Customer experience
- Operational efficiency

---

# Project Journey

**Real-Life Observation**

↓

**Business Logic and Retail System Design**

↓

**Excel Distribution and Identity Libraries**

↓

**Python Data Generation**

↓

**1.8M+ Retail Transaction Lines**

↓

**SQL Data Modeling and Validation**

↓

**SQL Business Analysis**

↓

**Advanced Power BI Visual Analytics**
