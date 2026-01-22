# Energy-Company-SQL-Case-Study
This case study analyzes an energy company’s operations using SQL to understand customer energy consumption patterns, energy production efficiency, carbon emissions, and the impact of sustainability initiatives.  The goal is to demonstrate business-first SQL analysis , not just writing queries, but extracting insights that can support decisions.


🎯 Business Objectives

The analysis focuses on answering the following key questions:

Who are the highest energy-consuming customers?

How do consumption patterns differ across customer segments?

What energy types dominate customer demand?

Which production plants contribute most to carbon emissions?

How efficient are different production plants?

Which sustainability initiatives are the most effective over time?

🗂️ Dataset Description

The project uses an Energy Company schema consisting of five tables:

1️⃣ Customers

Stores customer details and segmentation.

customer_id (PK)

name

address

segment (Residential / Commercial / Industrial)

join_date

2️⃣ Energy_Consumption

Tracks customer energy usage and cost over time.

consumption_id (PK)

customer_id (FK)

date

energy_type

amount_kwh

cost_usd

3️⃣ Energy_Production

Records energy produced by plants, including cost and emissions.

production_id (PK)

production_plant_id (FK)

date

energy_type

amount_kwh

cost_usd

carbon_emission_kg

4️⃣ Production_Plants

Contains metadata about energy production plants.

plant_id (PK)

plant_name

location

capacity_kwh

energy_type

5️⃣ Sustainability_Initiatives

Tracks sustainability programs implemented by the company.

initiative_id (PK)

initiative_name

start_date

end_date

energy_savings_kwh

🛠️ Tools & Technologies

SQL (MySQL)

Window Functions (ROW_NUMBER, RANK, LAG, LEAD, FIRST_VALUE, LAST_VALUE)

Common Table Expressions (CTEs)

Aggregations & Time-based Analysis

🧪 Project Structure & Methodology
Step 1: Define Business Objective

Clarified analytical goals aligned with customer behavior, production efficiency, and sustainability impact.

Step 2: Data Understanding

Reviewed table relationships, grain (row-level meaning), and key metrics.

Step 3: Analytical Questions

Defined targeted business questions before writing SQL.

Step 4: Data Preparation

Validated critical fields

Checked for duplicates

Filtered invalid values

Created clean, reusable aggregations (monthly & daily levels)

Step 5: Customer Consumption Analysis

Top energy-consuming customers

Segment-wise consumption comparison

Energy type demand analysis

Monthly consumption trends

Consistent vs spike-based consumption

Cost per kWh by customer segment

Step 6: Advanced Analysis

Carbon emissions per production plant (kg/kWh)

Ranking plants by efficiency and emissions

Energy production distribution by type

Monthly production trends using LAG() and LEAD()

Top production records by energy type

Cumulative consumption analysis

First vs last consumption analysis (2023)

Sustainability initiative effectiveness (total vs average monthly savings)

📊 Key Insights

Industrial customers consume the highest and most consistent energy volumes.

Electricity and gas dominate customer energy demand.

Certain production plants generate disproportionately high carbon emissions per kWh.

Sustainability initiatives vary significantly in their monthly effectiveness, highlighting opportunities for optimization.

Window functions are critical for time-based and ranking analysis in real business scenarios.

📈 Business Impact

This analysis can support:

Targeted energy efficiency programs

Carbon reduction prioritization

Customer segmentation strategy

Production optimization

Sustainability investment decisions

📂 Repository Contents
energy-company-sql-case-study/
│
├── README.md
├── energy_company_case_study.sql

🚀 How to Use

Load the schema into a MySQL environment

Execute queries section-by-section from the SQL file

Review insights embedded as comments in the SQL script

👤 Author

Upasana Choudhary
Data Analyst | SQL | Business Analytics | Sustainability Analytics
