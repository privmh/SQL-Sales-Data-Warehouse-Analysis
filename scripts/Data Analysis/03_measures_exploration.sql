/*
===============================================================================
Purpose:
    This script summarizes key business metrics from the sales fact table in 
    the Gold layer. It provides total and distinct counts, as well as 
    aggregations useful for reporting and dashboarding.

Details:
    - Calculates total sales, quantity, and average selling price.
    - Provides total and distinct counts of orders, customers, and products.
    - Consolidates key metrics into a unified, labeled output for quick review.
===============================================================================
*/

-- Total Sales
SELECT SUM(sales) AS total_sales FROM gold.fact_sales;

-- Total Quantity
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales;

-- Average Selling Price
SELECT AVG(price) AS avg_selling_price FROM gold.fact_sales;

-- Total Orders (with and without DISTINCT)
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales;

-- Total Customers (with and without DISTINCT)
SELECT COUNT(customer_key) AS total_customers FROM gold.fact_sales;
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales;

-- Total Products (with and without DISTINCT)
SELECT COUNT(product_key) AS total_products FROM gold.fact_sales;
SELECT COUNT(DISTINCT product_key) AS total_products FROM gold.fact_sales;

-- Unified Summary of Key Measures
SELECT 'Total Sales' AS Measure_amount , SUM(sales) AS Measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Quantity'		, SUM(quantity)					FROM gold.fact_sales
UNION ALL 
SELECT 'AVG Selling Price'  , AVG(price)					FROM gold.fact_sales
UNION ALL 
SELECT 'Total Orders'		, COUNT(DISTINCT order_number)	FROM gold.fact_sales
UNION ALL 
SELECT 'Total Customers'	, COUNT(DISTINCT customer_key)  FROM gold.fact_sales
UNION ALL 
SELECT 'Total Products'		, COUNT(DISTINCT product_key)	FROM gold.fact_sales;
