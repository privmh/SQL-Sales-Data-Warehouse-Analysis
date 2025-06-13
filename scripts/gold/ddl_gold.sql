-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
SELECT DISTINCT 
	ci.cst_gndr AS gender,    
	ca.gen		AS gender 
FROM	silver.crm_cust_info ci
LEFT JOIN	silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid;

SELECT		customer_key , COUNT(*) 
FROM		gold.dim_customers
GROUP BY	customer_key
HAVING		COUNT(*)>1;
-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
SELECT product_key,count(*)  
FROM gold.dim_products
GROUP BY product_key
HAVING count(*)>1;
-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
SELECT *
FROM gold.fact_sales s 
LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_products  p
	ON s.product_key = p.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;
