/*
===============================================================================
Product Performance View: gold.report_products
===============================================================================
Purpose:
    - To create a reusable SQL view for product performance tracking.
    - Enables consistent reporting across dashboards and analyses.

Key Metrics Generated:
    - Total Orders, Sales, Quantity, Unique Customers
    - Lifespan and Recency
    - Product Segments: High-Performer, Mid-Range, Low-Performer
    - Average Selling Price (ASP)
    - Average Order Revenue (AOR)
    - Average Monthly Revenue

SQL Features Used:
    - View Definition with IF EXISTS + DROP logic
    - CTEs (Common Table Expressions)
    - Aggregates: SUM(), COUNT(), MAX(), MIN(), AVG()
    - Date Calculations: DATEDIFF(), GETDATE()
    - CASE Expressions for segmentation
    - NULLIF to avoid divide-by-zero errors

Output:
    - A persistent view named `gold.report_products` summarizing product KPIs
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.sub_category,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  
),
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        sub_category,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(CAST(sales AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        sub_category,
        cost
)
SELECT 
    product_key,
    product_name,
    category,
    sub_category,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregations;
