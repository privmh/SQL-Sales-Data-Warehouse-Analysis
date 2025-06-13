/*
===============================================================================
QUALITY CHECKS SCRIPT
===============================================================================

Purpose:
    This script performs a series of data quality checks to validate consistency, 
    accuracy, and standardization across the 'silver' layer datasets. The checks 
    include validation for:

    - Null or duplicate primary keys.
    - Leading/trailing spaces in string fields.
    - Standardized field values.
    - Logical and valid date ranges.
    - Numeric data integrity and consistency across related fields.

Usage Guidelines:
    - Run this script after loading data into the Silver Layer.
    - Review all outputs and investigate anomalies.
    - Address any data issues prior to further processing or reporting.

Checked Tables:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2

===============================================================================
*/

-- ====================================================================
-- CHECKING 'silver.crm_cust_info'
-- ====================================================================

-- CHECK FOR NULLs OR DUPLICATES IN PRIMARY KEY
SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- CHECK FOR UNWANTED SPACES
SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key <> TRIM(cst_key);

-- CHECK FOR UNWANTED SPACES
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname <> TRIM(cst_firstname);

-- CHECK FOR UNWANTED SPACES
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname <> TRIM(cst_lastname);

-- CHECK FOR UNWANTED SPACES
SELECT cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status <> TRIM(cst_marital_status);

-- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- CHECK FOR NULLs OR DUPLICATES IN PRIMARY KEY
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- CHECK FOR UNWANTED SPACES
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

-- CHECK FOR NULLs OR NEGATIVE VALUES IN COST
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- CHECK FOR INVALID DATE ORDERS (START DATE > END DATE)
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- CHECK FOR INVALID DATES
SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE 
	sls_order_dt <= 0 OR
	LEN(sls_order_dt) <> 8 OR
	sls_order_dt > 20250101 OR
	sls_order_dt < 19000101;

-- CHECK FOR INVALID DATES
SELECT *
FROM bronze.crm_sales_details
WHERE 
	sls_ship_dt <= 0 OR
	LEN(sls_ship_dt) <> 8 OR
	sls_ship_dt > 20250101 OR
	sls_ship_dt < 19000101;

-- CHECK FOR INVALID DATES
SELECT  
	NULLIF(sls_order_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE 
	sls_due_dt <= 0 OR
	LEN(sls_due_dt) <> 8 OR
	sls_due_dt > 20250101 OR
	sls_due_dt < 19000101;

-- CHECK FOR INVALID DATE ORDERS (ORDER DATE > SHIPPING/DUE DATES)
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
	OR sls_order_dt > sls_due_dt;

-- CHECK DATA CONSISTENCY: SALES = QUANTITY * PRICE
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price 
FROM bronze.crm_sales_details
WHERE 
	sls_sales <> sls_quantity * sls_price 
	OR sls_sales IS NULL 
	OR sls_sales <= 0 
	OR sls_quantity <= 0
	OR sls_quantity IS NULL
	OR sls_price <= 0
	OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

	
-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- IDENTIFY OUT-OF-RANGE DATES
SELECT * 
FROM bronze.erp_cust_az12
WHERE bdate < '1920-01-01' OR bdate > GETDATE();

-- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;


-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- DATA STANDARDIZATION & CONSISTENCY
SELECT distinct cntry
FROM bronze.erp_loc_a101

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- CHECK FOR UNWANTED SPACES
SELECT * 
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
	OR subcat != TRIM(subcat) 
	OR maintenance != TRIM(subcat);

-- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT cat 
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat 
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance 
FROM bronze.erp_px_cat_g1v2;

