/*
===============================================================================
Stored Procedure: load_silver
===============================================================================
Purpose:
    Performs the ETL (Extract, Transform, Load) process to populate 
    the 'silver' schema tables using cleansed and transformed data 
    from the 'bronze' schema.

Overview:
    This procedure executes the following steps:
        - Truncates target Silver layer tables.
        - Extracts the latest and relevant data from Bronze layer tables.
        - Transforms the data (e.g., trimming, formatting, conversions).
        - Loads the cleansed data into corresponding Silver layer tables.
        - Tracks and logs execution time for each table load.

Tables Affected:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2

Error Handling:
    Includes a TRY-CATCH block to log any errors that occur during processing.

Parameters:
    None. 
    This stored procedure does not accept any input parameters or return values.

Usage:
    EXEC silver.load_silver;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';
		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- Truncate and insert into silver.crm_cust_info with execution time tracking.
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_cust_info 
		INSERT INTO silver.crm_cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		)
		select 
			cst_id ,
			cst_key ,
			TRIM(cst_firstname) as cst_firstname,
			TRIM(cst_lastname) as cst_lastname,
			case 
				when cst_marital_status= 'S' then 'Single' 
				when cst_marital_status = 'M' then 'Married'
				else 'n/a'
			end as cst_marital_status,
			case 
				when cst_gndr = 'M' then 'Male' 
				when cst_gndr = 'F' then 'Female'
				else 'n/a'
			end as cst_gndr,
			cst_create_date
		from (
			SELECT *, 
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
		) t
		WHERE flag_last = 1 AND cst_id IS NOT NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- Truncate and insert into silver.crm_prd_info with execution time tracking.
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_prd_info 
		insert into silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		) 
		select
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,  -- Extract category ID
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,		-- Extract product key
			prd_nm,
			isnull(prd_cost,0) as prd_cost,
			CASE 
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line_test, 
			cast(prd_start_dt as DATE) as prd_start_dt,
			cast(
				LEAD(prd_start_dt) 
				OVER (PARTITION BY prd_key order by prd_start_dt) -1 
				as date
				) as prd_end_dt
		from bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- Truncate and insert into silver.crm_sales_details with execution time tracking.
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.crm_sales_details
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case 
				when sls_order_dt=0 or len(sls_order_dt)<>8 then NULL
				else 
					cast(cast(sls_order_dt as varchar) as DATE)
			end as sls_order_dt,
			case 
				when sls_ship_dt=0 or len(sls_ship_dt)<>8 then NULL
				else 
					cast(cast(sls_ship_dt as varchar) as DATE)
			end as sls_ship_dt,
			case 
				when sls_due_dt=0 or len(sls_due_dt)<>8 then NULL
				else 
					cast(cast(sls_due_dt as varchar) as DATE)
			end as sls_due_dt,
			case 
				when sls_sales <=0 or sls_sales is null or sls_sales <> sls_quantity * abs(sls_price) 
					then sls_quantity * abs(sls_price)
				else sls_sales
			end as sls_sales,
			sls_quantity,
			case 
				when sls_price <=0 or sls_sales is null or sls_sales <> sls_quantity * abs(sls_price) 
					then sls_sales / NULLIF(sls_quantity, 0)
				else sls_price
			end as sls_price
		from bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';
		
		-- Truncate and insert into silver.erp_cust_az12 with execution time tracking.	
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_cust_az12
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		select
			case 
				when cid like 'NAS%' THEN substring(cid,4,len(cid)) 
				ELSE cid
			end as cid,
			case 
				when bdate > GETDATE() then NULL
				ELSE bdate
				END AS bdate,
			case 
				when upper(trim(gen)) in ('M','MALE') then 'Male' 
				when upper(trim(gen)) in ('F','FEMALE') then 'Female' 
				else 'n/a'
			end as gen
		from bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- Truncate and insert into silver.erp_loc_a101 with execution time tracking.
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_loc_a101
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		select 
			REPLACE(cid,'-',''),
			case
				when upper(trim(cntry)) = 'DE' THEN 'Germany'
				when upper(trim(cntry)) in ('US','USA') THEN 'United States'
				when trim(cntry) = '' or cntry is null then 'n/a'
				else 
					TRIM(cntry)
			end as cntry
		from bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		-- Truncate and insert into silver.erp_px_cat_g1v2 with execution time tracking.
		SET @start_time = GETDATE();
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		select
			id,
			cat,
			subcat,
			maintenance
		from bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
	SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY 
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
	END CATCH
END 
