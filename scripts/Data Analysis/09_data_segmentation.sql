/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To categorize products and customers into meaningful segments.
    - Helps understand pricing tiers and customer value.
    - Supports targeted marketing and inventory strategies.

Segments Created:
    • Product Segments by Cost Range:
        - Below 100
        - 100–500
        - 501–1000
        - Above 1000
    • Customer Segments by Spending and Lifespan:
        - VIP: High spending & long relationship
        - Regular: Low spending & long relationship
        - New: Recently acquired customers

SQL Concepts Used:
    - CTEs (Common Table Expressions)
    - Conditional Logic with CASE
    - Aggregate Functions: SUM(), COUNT(), MIN(), MAX()
    - Date Function: DATEDIFF()

Output:
    - Product count per cost segment
    - Customer count per value segment
===============================================================================
*/

-- Segment products based on cost ranges
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 501 AND 1000 THEN '501-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- Segment customers based on spending and engagement lifespan
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
