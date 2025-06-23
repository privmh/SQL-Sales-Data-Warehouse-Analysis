/*
===============================================================================
Purpose:
    This script identifies top-performing and least-performing products and 
    customers based on sales revenue. It helps prioritize key contributors and 
    uncover underperformers for strategic decision-making.

Details:
    - Top 5 best-selling products by total revenue.
    - Bottom 5 least-selling products by total revenue.
    - Top 10 customers ranked by total revenue.
===============================================================================
*/

-- Top 5 best-selling products by total revenue
SELECT TOP 5 
    p.product_name,
    SUM(s.sales) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Bottom 5 least-selling products by total revenue
SELECT TOP 5 
    p.product_name,
    SUM(s.sales) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- Top 10 customers by total revenue
SELECT TOP 10
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
