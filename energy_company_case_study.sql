/* STEP 1: Project Objective

 The objective of this analysis is to evaluate customer energy consumption patterns, 
 assess energy production efficiency and environmental impact across production plants, and 
 measure the effectiveness of sustainability initiatives.
 By analyzing consumption trends, production costs, carbon emissions, and initiative timelines, 
 this project aims to identify high-impact areas where cost optimization, efficiency improvements, 
 and sustainability efforts can be most effective. */
 

use cn_clc;
show tables;

/*
STEP 2: Data Understanding
Tables:
- customers
- energy_consumption
- energy_production
- production_plants
- sustainability_initiatives
*/

select * from customers;
select * from energy_consumption;
select * from energy_production;
select * from production_plants;
select * from sustainability_initiatives;


/*
STEP 3: Analytical Questions
1. Highest energy-consuming customers
2. Production cost & efficiency
3. Carbon emissions by plant
4. Impact of sustainability initiatives
*/


/*
STEP 4 — Data Preparation
- Monthly aggregation where required
- Handle NULL / zero values
*/


/*
DATA CLEANING 1:
Remove records where critical metrics are NULL
*/

SELECT * FROM energy_consumption
WHERE customer_id IS NOT NULL AND date IS NOT NULL AND amount_kwh IS NOT NULL;


/*
DATA CLEANING 2:
Detect exact duplicates 
*/
SELECT customer_id, date, energy_type, amount_kwh, COUNT(*) AS cnt
FROM energy_consumption
GROUP BY customer_id, date, energy_type, amount_kwh
HAVING COUNT(*) > 1;


/*
DATA CLEANING 3:
Exclude invalid energy values
*/
SELECT * FROM energy_consumption
WHERE amount_kwh > 0;


/*
FINAL PREP:
Monthly customer consumption with necessary cleaning
*/

WITH monthly_customer_consumption AS (
    SELECT
        customer_id,
        DATE_FORMAT(date, '%Y-%m') AS month,
        SUM(amount_kwh) AS monthly_kwh,
        SUM(cost_usd) AS monthly_cost
    FROM energy_consumption
    WHERE
        customer_id IS NOT NULL
        AND date IS NOT NULL
        AND amount_kwh > 0
    GROUP BY
        customer_id,
        DATE_FORMAT(date, '%Y-%m')
)
SELECT * FROM monthly_customer_consumption;



-- STEP 5: CUSTOMER CONSUMPTION ANALYSIS


-- 5.1: Who are the top energy-consuming customers?

SELECT
    c.customer_id,
    c.name,
    c.segment,
    SUM(ec.amount_kwh) AS total_kwh_consumed,
    SUM(ec.cost_usd) AS total_cost_usd
FROM customers c
JOIN energy_consumption ec
    ON c.customer_id = ec.customer_id
GROUP BY c.customer_id, c.name, c.segment
ORDER BY total_kwh_consumed DESC;

-- INSIGHT: High consumers = key revenue drivers, also biggest targets for efficiency programs


-- 5.2 How do residential vs commercial vs industrial customers differ?

SELECT c.segment, 
SUM(ec.amount_kwh) AS total_kwh_consumed,
AVG(ec.amount_kwh) AS AVG_kwh_consumed
FROM customers c
JOIN energy_consumption ec
    ON c.customer_id = ec.customer_id
GROUP BY c.segment
ORDER BY total_kwh_consumed DESC;

-- INSIGHT: Industrial → high volume, stable; Residential → seasonal spikes; Commercial → business-hour patterns


-- 5.3: What types of energy are customers consuming?

SELECT energy_type, 
SUM(amount_kwh) AS total_energy_consumed,
COUNT(DISTINCT customer_id) AS customer_count
FROM energy_consumption
GROUP BY energy_type
ORDER BY SUM(amount_kwh) DESC;

-- INSIGHT: Mostly consuming electricity and gas, with this analysis business can Demand planning, Infrastructure investment, Sustainability alignment


-- 5.4: monthly consumption trend analysis

SELECT 
CAST(DATE_FORMAT(date, '%Y-%m-01') AS DATE) AS month,
sum(amount_kwh) as total_kwh
FROM energy_consumption
GROUP BY CAST(DATE_FORMAT(date, '%Y-%m-01') AS DATE)
ORDER BY CAST(DATE_FORMAT(date, '%Y-%m-01') AS DATE);

-- INSIGHT: It will Detect seasonal trends, Forecast demand, Cost planning



-- 5.5: Who consumes consistently high energy (not just spikes)?

with monthly_usage as (
select 
customer_id,
CAST(DATE_FORMAT(date, '%Y-%m-01') AS DATE) AS month,
sum(amount_kwh) as monthly_kwh
from energy_consumption
group by customer_id, CAST(DATE_FORMAT(date, '%Y-%m-01') AS DATE)
order by sum(amount_kwh) desc
)
select 
customer_id,
avg(monthly_kwh) as avg_monthly_kwh
from monthly_usage
group by customer_id
order by avg(monthly_kwh) desc;


-- 5.6 Cost Efficiency: Cost per kWh by Segment

-- Which segment is more expensive to serve?

SELECT c.segment, 
SUM(ec.cost_usd) / SUM(ec.amount_kwh) AS cost_per_kwh
FROM customers c
JOIN energy_consumption ec
    ON c.customer_id = ec.customer_id
GROUP BY c.segment;

-- Business takeaway: Pricing strategy, Margin optimization, Subsidy planning

-- STEP 6: ADVANCED ANALYSIS


/*  
Problem statement
The sustainability team is concerned about the carbon emissions of different production plants 
and wants to identify the top 5 plants with the highest average carbon emissions per unit of energy produced.

Write a query to list the top 5 production plants with the highest average carbon emissions per unit of energy produced (in kg/kWh). 
Include the plant name, location, and average carbon emissions per kWh. */

select pp.plant_name,
pp.location,
sum(ep.carbon_emission_kg)/sum(ep.amount_kwh) as avg_carbon_emission_per_kwh
from production_plants pp 
join energy_production ep
on pp.plant_id = ep.production_plant_id
group by  pp.plant_name, pp.location
order by avg_carbon_emission_per_kwh desc 
limit 5;


/* 
Problem statement
The sustainability team wants to evaluate the performance of various sustainability initiatives based on the energy savings achieved.

Write a query to list the top 3 sustainability initiatives based on the total energy savings achieved. 
Include the initiative name, start date, end date, and total energy savings. 
The resulting table should be in descending order for the total energy savings column.
*/

select initiative_name,
start_date,
end_date,
sum(energy_savings_kwh) as energy_savings_kwh
from sustainability_initiatives
group by  initiative_name, start_date, end_date
order by energy_savings_kwh desc
limit 3;


/* 
Problem Statement
The energy production team wants to understand the distribution of energy production amounts.

Write a query to list all energy production records along with a new column 
that shows the total energy production amount for each energy_type. 
The resulting table should contain production ID, production plant ID, the date of production, energy type,
 amount of production and the total amount according to the energy type.
*/

select 
production_id, production_plant_id,
date, energy_type,
amount_kwh,
sum(amount_kwh)over(partition by energy_type) as total_energy_by_type
from energy_production;


/*
Problem statement
The energy production team wants to rank the energy production records based on 
the production amount within each energy type.

Write a SQL query that lists all energy production records 
and includes a new column for ranking the production amount within each energy type. 
The rank should be calculated such that it reflects the relative position of each production record 
within its respective energy type, based on the production amount. 
The resulting output should contain the customer ID, customer name, total consumption for the customer, 
and the average monthly consumption.
*/

select
production_id,
production_plant_id,
date, energy_type,
amount_kwh,
rank()over(partition by energy_type order by amount_kwh desc ) as rank_within_type
from energy_production;


/*
Problem statement
The customer analytics team wants to analyze the cumulative energy consumption for each customer over time.

Write a query to list all energy consumption records while also providing a new column 
that displays the cumulative energy consumption for each customer over time. 
The cumulative consumption should be calculated in a way that adds up the energy consumed
 by each customer up to each record, based on the date of consumption. 
 The resulting table should contain consumption ID, customer ID, date of consumption, 
 energy type, amount consumed by the customer, and the cumulative consumption.
*/

select consumption_id,
customer_id,
date,
energy_type,
amount_kwh,
sum(amount_kwh)over(partition by customer_id order by date asc) as cumulative_consumption
from energy_consumption;


/*
Problem statement
The energy production team wants to analyze the monthly changes in energy production 
for each plant to understand trends and fluctuations.

Write a query to list the monthly energy production amounts for each plant 
along with the previous month's production amount and the next month's production amount 
using the LAG() and LEAD() functions. Include columns for the plant ID, month, current month's production amount, 
previous month's production amount, and next month's production amount
*/

with monthly as (
select 
production_plant_id,
CAST(DATE_FORMAT(date, '%y-%m-01') AS DATE) as month,
sum(amount_kwh) as current_month_production
from energy_production
group by production_plant_id, CAST(DATE_FORMAT(date, '%y-%m-01') AS DATE) 
)
select *,
lag( current_month_production)over(partition by production_plant_id order by month) as previous_month_production,
lead( current_month_production)over(partition by production_plant_id order by  month) as next_month_production
from monthly;


/*
Problem statement
The production team wants to identify the top 3 highest energy production records 
for each energy type to understand which plants are performing best.

Write a query to list the production plant ID, energy type, date, 
and amount of the top 3 highest energy production records for each energy type. 
Ensure that you assign a unique rank to each record within its energy type category. 
The resulting table should contain the production plant ID, energy type, date of the production
 and the amount that the plant has produced. 
 The output table should be in ascending order for energy type and the ranking.
*/

with ranked_production as (select
production_plant_id,
energy_type,
date,
amount_kwh,
row_number()over(partition by energy_type order by amount_kwh desc ) as rn 
 from energy_production
)
select
production_plant_id,
energy_type,
date,
amount_kwh
from ranked_production 
where rn <=3
order by energy_type, rn
;


/*
Problem statement
The management wants to rank the production plants based on their average monthly energy production 
to recognize the most consistent performers.

Write a query to rank the production plants based on their average monthly energy production. 
Include columns for plant ID, month, average monthly production, and rank. 
Ensure that your query accurately calculates the average monthly production for each plant 
and assigns ranks that reflect the plants' performance in terms of energy production consistency. 
The resulting table should be in ascending order for the month and the ranking column.
*/

with monthly_prod as (
select
production_plant_id,
date_format(date, '%Y-%m') as month,
avg(amount_kwh) as avg_monthly_production
from energy_production
group by production_plant_id,
date_format(date, '%Y-%m') 
)
select *, 
row_number()over(partition by month order by  avg_monthly_production desc ) as ranking
from monthly_prod;


/*
Problem statement
The sustainability team is interested in identifying which initiatives have 
consistently achieved high energy savings across multiple periods. 
They need to analyze and rank the sustainability initiatives based on their total energy savings.

Write a query to rank the sustainability initiatives based on their total energy savings. 
The query should include columns for the initiative name, start date, end date, total energy savings, 
and their rank based on these savings.
*/

select
initiative_name,
start_date, 
end_date,
energy_savings_kwh,
row_number()over(order by energy_savings_kwh desc ) as initiative_rank
from sustainability_initiatives;


/*
Problem statement
The energy production team wants to analyze the changes in energy production amounts 
between consecutive months for each plant to identify trends and fluctuations.

Write a query to list the monthly energy production amounts for each plant 
along with the previous month's production amount and the next month's production amount. 
Include columns for the plant ID, month, current month's production amount, 
previous month's production amount, and next month's production amount. 
The resulting table should be order in ascending order for the production_plant_id and the month column.
*/

with monthly_prod as (
    select
    production_plant_id, 
    date_format(date, '%Y-%m') as month,
    sum(amount_kwh) as current_month_production
    from energy_production
    group by production_plant_id, 
    date_format(date, '%Y-%m') 
)
select *,
lag(current_month_production)over(partition by production_plant_id order by month) as previous_month_production,
lead(current_month_production)over(partition by production_plant_id order by month) as next_month_production
from monthly_prod;
use cn_clc;

/*
Problem statement
The customer analytics team is focused on understanding the energy consumption patterns of customers 
throughout the year 2023. They aim to identify both the first and last recorded energy consumption amounts 
for each customer during this time period.

The energy_consumption table contains data on energy usage, including multiple entries per day 
and across different energy types (e.g., gas, electricity). Your task is to write a SQL query 
that will list each customer's ID along with their first and last total daily consumption values in 2023. 
Return the resulting table in ascending order by customer ID.
*/

with daily_consumption as(
select 
customer_id,
date,
sum(amount_kwh) as total_kwh
from energy_consumption
where  year(date) = 2023
group by customer_id,date
 ),
 first_last_values as (
select  customer_id,
ROUND(first_value(total_kwh)over(partition by customer_id order by date),2)  as first_consumption,
ROUND(last_value(total_kwh)over(partition by customer_id order by date
   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),2) as last_consumption
from daily_consumption
)
select DISTINCT customer_id, first_consumption, last_consumption
from  first_last_values
order by customer_id;


/*
Problem statement
The customer analytics team wants to analyze the total and monthly energy consumption 
for each customer to identify high consumption patterns.

Write a query to list each customer's total energy consumption and their average monthly consumption. 
The output table should contain the customer_id, name, total consumption, and average monthly energy consumption. 
The resulting table should be ordered in ascending order for the customer ID column.
*/

with monthly_consumption as (
select ec.customer_id,
date_format(ec.date, '%Y-%m') as month,
sum(ec.amount_kwh) as monthly_consumed
from energy_consumption ec 
group by  ec.customer_id, date_format(ec.date, '%Y-%m') 
)
select c.customer_id, c.name,
sum(mc.monthly_consumed) as total_consumed,
avg(mc.monthly_consumed) as avg_monthly_consumed
from monthly_consumption mc
join customers c
on c.customer_id = mc.customer_id
group by c.customer_id , c.name
order by mc.customer_id;


/*
Problem statement
The sustainability team at the energy company is conducting a comprehensive environmental impact assessment 
of their production facilities. They need to identify which production plants are contributing the most to carbon emissions, 
enabling them to prioritize eco-friendly initiatives and improvements.

Your task is to create a detailed SQL query that analyzes carbon emission data across all production plants. 
This query should utilize the energy_production and production_plants tables to calculate both the average 
and total carbon emissions for each plant. The final output should list each production 
plant's ID, name, average carbon emissions, and total carbon emissions, ordered by the plant ID for easy reference.
*/

select
pp.plant_id,
pp.plant_name,
avg(ep.carbon_emission_kg) as average_carbon_emissions,
sum(ep.carbon_emission_kg) as total_carbon_emissions
from energy_production ep 
join production_plants pp 
on pp.plant_id = ep.production_plant_id
group by pp.plant_id, pp.plant_name
order by pp.plant_id asc;


/*
Problem statement
The management wants to understand the impact of sustainability initiatives on energy savings 
and identify the most effective initiatives.

Write a query to list each initiative's total energy savings and the average monthly energy savings. 
The final output should present the initiative ID, name, total savings, and average monthly savings, ordered by initiative ID.
*/
with initiative_months as (
select 
initiative_id,
initiative_name, 
energy_savings_kwh,
(timestampdiff(month, start_date, end_date)+1) as number_of_active_months_per_initiative
from sustainability_initiatives
)
select 
initiative_id,
initiative_name, 
energy_savings_kwh as total_savings,
round(energy_savings_kwh/number_of_active_months_per_initiative, 2) as avg_monthly_savings
from initiative_months
order by initiative_id;





/*
STEP 7: Key Business Takeaways

- Industrial customers consume the highest energy consistently
- Electricity dominates customer consumption patterns
- Certain plants show disproportionately high carbon emissions per kWh
- Sustainability initiatives vary significantly in monthly effectiveness

These insights can guide:
- Targeted efficiency programs
- Carbon reduction investments
- Customer segmentation strategies
*/


