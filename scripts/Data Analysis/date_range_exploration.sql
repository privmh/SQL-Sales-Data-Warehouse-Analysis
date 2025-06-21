/*
===============================================================================
Purpose:
    This script analyzes the temporal range of key date fields across fact and 
    dimension tables. It helps understand data currency and customer age 
    distribution.

Details:
    - Calculates the first and last order dates and the total number of months 
      between them from the sales fact table.
    - Identifies the youngest and oldest birth dates in the customer dimension 
      and computes their respective ages.
===============================================================================
*/

-- Explore order date range in the sales fact table
SELECT
    MAX(order_date) AS last_order_date,
    MIN(order_date) AS first_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Explore customer age range using birth dates
SELECT
    MAX(birth_date) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS youngest_age,
    MIN(birth_date) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS oldest_age
FROM gold.dim_customers;
