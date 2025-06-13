/*
===============================================================================
DDL Script: Validate Gold Layer Views
===============================================================================
Script Purpose:
    This script performs validation checks on views in the Gold layer of the 
    data warehouse. The Gold layer contains the final dimension and fact tables 
    structured in a Star Schema for analytical use.

    These checks help ensure data integrity by identifying:
        - Inconsistencies in gender data between source systems
        - Duplicate keys in dimension tables
        - Orphaned records in the fact table (missing dimension references)

Usage:
    - Run this script after creating or updating Gold layer views to verify 
      data quality before using them in analytics or reporting.
===============================================================================
*/
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
