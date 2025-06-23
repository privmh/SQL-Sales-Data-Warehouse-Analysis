/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To understand the contribution of each product category to total sales.
    - Helps identify dominant and underperforming categories.
    - Useful in visualizations like pie charts or stacked bars.

SQL Concepts Used:
    - CTE (Common Table Expression)
    - Aggregate Function: SUM()
    - Window Function: SUM() OVER()
    - Type Casting and String Formatting

Output:
    - Category-wise sales
    - Total sales across all categories
    - Percentage contribution of each category to overall sales
===============================================================================
*/

-- Calculate sales percentage contribution by product category
WITH category_sales AS (
    SELECT 
        p.category,
        SUM(s.sales) AS total_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.category
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(
        ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2),
        '%'
    ) AS sales_percentage
FROM category_sales
ORDER BY total_sales DESC;
