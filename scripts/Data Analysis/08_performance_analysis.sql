/*
===============================================================================
Performance Analysis
===============================================================================
Purpose:
    - To evaluate year-over-year performance of individual products.
    - Compare current year sales against average and previous year sales.
    - Identify trends such as growth, decline, or consistency.

SQL Concepts Used:
    - CTE (Common Table Expression)
    - Aggregate Functions: SUM(), AVG()
    - Window Functions: 
        - AVG() OVER(PARTITION BY ...)
        - LAG() OVER(PARTITION BY ... ORDER BY ...)
    - Conditional Logic: CASE statements

Output:
    - Yearly sales per product
    - Average sales across all years for each product
    - Difference from average and previous year
    - Performance labels (Above/Below Avg, Increase/Decrease)
===============================================================================
*/

-- Analyze product performance trends year over year
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
