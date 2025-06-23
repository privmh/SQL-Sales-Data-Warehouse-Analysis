/*
===============================================================================
Customer Profiling Report
===============================================================================
Purpose:
    - To generate detailed customer-level metrics and segments.
    - Support customer lifecycle analysis, targeting, and retention strategies.
    - Identify high-value customers and behavioral trends.

Key Metrics Calculated:
    - Age and Age Grouping
    - Total Orders, Sales, Quantity, Products Purchased
    - Lifespan (Months Active)
    - Last Order Date & Recency
    - Customer Segments (VIP, Regular, New)
    - Average Order Value (AOV)
    - Average Monthly Spend

SQL Concepts Used:
    - CTEs (Common Table Expressions)
    - Date Functions: DATEDIFF(), GETDATE()
    - Aggregations: SUM(), COUNT(), MAX()
    - Conditional Logic: CASE

Output:
    - One record per customer with demographics and purchasing behavior
===============================================================================
*/

WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(year, c.birth_date, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL
),
customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- Compute Average Order Value (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    -- Compute Average Monthly Spend
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation;
