# JRAD Retail Data System

## Project Overview

The JRAD Retail Data System is a full-scale retail data engineering and analytics project inspired by real-life Nigeria Superstores operations and customer shopping behavior.

The project was designed to simulate a realistic retail environment, covering customer behavior, product purchasing patterns, branch performance, loyalty activity, operational events, and customer experience.

Rather than using a simple ready-made dataset, the project involved designing and building a structured retail data ecosystem from the ground up.

---

## Business Problem

Retail businesses generate large volumes of transactional and operational data. However, raw data alone does not provide meaningful business value.

The objective of this project was to create a realistic retail data environment that could be used to analyze:

- Sales and revenue performance
- Customer purchasing behavior
- Branch performance
- Product and category performance
- Customer loyalty and retention
- Payment behavior
- Operational efficiency
- Seasonal and event-driven shopping patterns

---

## Project Scope

The JRAD Retail Data System simulates retail activity across multiple branches and includes:

- Customer master data
- Product master data
- Sales transactions
- Branch information
- Customer loyalty behavior
- Payment behavior
- Business events and seasonal patterns
- Customer experience and ratings
- Queue and operational metrics
- Product pricing history

The dataset was designed to contain realistic business relationships rather than randomly generated independent values.

---

## Data Generation Approach

A major part of this project involved building the data architecture before generating the final transactional dataset.

### Distribution Library

A custom Distribution Library was created in Excel to define realistic distributions and business rules.

This included:

- Branch-level customer distribution
- Age distributions
- Ethnic and demographic distributions
- Registration behavior
- Loyalty membership behavior
- Payment method distribution
- Basket size distribution
- Customer acquisition channels

These distributions were used as controlled inputs during data generation.

### Identity Library

A separate Identity Library was also created to generate realistic Nigerian customer identities.

The library included structured pools of:

- First names
- Surnames
- Gender-specific names
- Ethnic name groups

This helped create more realistic and diverse customer records.

### Python Data Generation

Python was used to generate and combine the datasets using the business rules and distributions created in Excel.

The generation process ensured relationships between different parts of the system, including:

- Customers and branches
- Customer demographics and behaviour
- Registration and loyalty status
- Shopping frequency and basket behaviour
- Payment preferences
- Seasonal events and demand patterns

---

## Business Events and Seasonality

The system incorporates simulated business events that influence retail activity.

Examples include:

- Salary Week
- Valentine's Day
- Easter Weekend
- Workers' Day
- Eid Holiday
- Mid-Year Inflation
- Back-to-School Season
- Independence Day
- Black Friday
- Christmas Season

Each event can influence:

- Customer traffic
- Basket size
- Customer spending
- Product demand
- Peak shopping hours

This allows the dataset to simulate more realistic changes in customer behaviour throughout the year.

---

## Data Architecture

The project consists of multiple interconnected datasets representing different areas of the retail business.

Key components include:

- Customer Master
- Product Master
- Sales Transactions
- Branch Information
- Business Events
- Customer Experience
- Queue Metrics
- Pricing History

The structure was designed to support downstream analysis using SQL, Power BI, Excel, and Python.

---

## Tools Used

- Microsoft Excel
- Python
- SQL
- Power BI

---

## Key Skills Demonstrated

- Data generation
- Data modelling
- Business rule design
- Synthetic data generation
- Distribution modelling
- Data architecture
- Data cleaning
- SQL analysis
- Business intelligence
- Dashboard development

---

## Project Workflow

1. Observed and documented realistic retail business behavior.
2. Designed the retail data structure.
3. Created the Product Master dataset.
4. Created the Distribution Library in Excel.
5. Created the Nigerian Identity Library.
6. Defined customer and business behavior rules.
7. Used Python to generate interconnected datasets.
8. Loaded and prepared the data for SQL analysis.
9. Developed analytical models and dashboards.

---

## Project Outcome

The final result is a structured retail data ecosystem designed for end-to-end analytics.

The project demonstrates how real-world observations and business logic can be transformed into a scalable synthetic data system that supports analysis, reporting, and business intelligence.

---

## Next Stage

The JRAD Retail Data System serves as the foundation for additional analytical projects, including:

- SQL Business Analysis
- Power BI Retail Dashboard
- Customer Loyalty and Retention Analysis
- Customer Experience Analysis

Each of these projects uses the JRAD Retail Data System as its underlying data source.
