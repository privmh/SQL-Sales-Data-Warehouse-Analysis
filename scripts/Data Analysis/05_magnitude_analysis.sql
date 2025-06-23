/*
===============================================================================
Purpose:
    This script performs magnitude-based analysis to identify the highest 
    contributors across various dimensions such as country, gender, product 
    category, cost, and revenue. It helps highlight key drivers of volume, value, 
    and performance within the dataset.

Details:
    - Counts customers by country and gender.
    - Counts and averages product data by category.
    - Aggregates total revenue per customer.
    - Aggregates total quantity sold by country.
===============================================================================
*/

-- Total customers by country
SELECT 
    country,
    COUNT(customer_key) AS Total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY COUNT(customer_key) DESC;

-- Total customers by gender
SELECT 
    gender,
    COUNT(customer_key) AS Total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY COUNT(customer_key) DESC;

-- Total products by category
SELECT 
    category,
    COUNT(product_key) AS Total_products
FROM gold.dim_products
GROUP BY category
ORDER BY COUNT(product_key) DESC;

-- Average cost per product category
SELECT 
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY AVG(cost) DESC;

-- Total revenue per customer
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(s.sales) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Total quantity sold by country
SELECT 
    c.country,
    SUM(s.quantity) AS total_quantity
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY 
    c.country
ORDER BY total_quantity DESC;
