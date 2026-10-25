/*
===============================================================================
Purpose:
    Create a stored procedure to load data from the Bronze layer into the
    Silver layer by truncating the target table and reloading the dataset.

Source Table:
    bronze.onlineretail

Target Table:
    silver.onlineretail

Load Strategy:
    Full Refresh (TRUNCATE and INSERT)

Additional Features:
    - Track data loading duration.
    - Display loading progress messages.
    - Handle and report errors using TRY...CATCH.

===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN 
	BEGIN TRY 
				PRINT '===========================================================================================';
				PRINT 'LOADING DATA TO SILVER LAYER '
				PRINT '===========================================================================================';

				DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
				PRINT '>> Truncating Table : silver.onlineretail';
				TRUNCATE TABLE silver.onlineretail
				PRINT '>> Inserting Data Into : silver.onlineretail';
				SET @batch_start_time=GETDATE();
				SET @start_time=GETDATE();

			
				WITH duplicates AS(
					SELECT *,
					ROW_NUMBER() OVER ( PARTITION BY stock_key,
													 invoice_key,
													 product_name,
													 quantity,
													 invoice_date,
													 unit_price,
													 customer_id,
													 country
										ORDER BY Invoice_date ) AS row_number1
					FROM bronze.onlineretail),
				unique_product AS (
					SELECT stock_key,
						   product_name,
						   ROW_NUMBER() OVER ( PARTITION BY stock_key ORDER BY invoice_date) row_number2
					FROM  bronze.onlineretail
					WHERE product_name IS NOT NULL AND unit_price>0),
				unit_price AS (
					SELECT stock_key,
						   unit_price,
						   quantity,
						   ROW_NUMBER() OVER ( PARTITION BY stock_key ORDER BY invoice_date) row_number3
					FROM  bronze.onlineretail
					WHERE unit_price>0 and quantity>0
					
				),	
				prepared AS (
					SELECT  
					a.invoice_key AS invoice_key,
					a.stock_key AS stock_key,
					CASE 
						WHEN a.product_name is null or unit_price<=0 THEN b.product_name
						ELSE a.product_name END AS product_name,
					a.quantity AS quantity,
					a.invoice_date AS invoice_date,
					a.unit_price AS unit_price,
					a.customer_id AS customer_id,
					a.country AS country
					FROM duplicates AS a
					INNER JOIN unique_product AS b
					ON a.stock_key=b.stock_key 
					WHERE a.row_number1=1 AND b.row_number2=1
				),final_silver_table as (
				SELECT 
					TRIM(x.invoice_key) as invoice_key,
					TRIM(x.stock_key) as stock_key,
					TRIM(x.product_name) as product_name,
					x.quantity as quantity,
					CASE 
						WHEN x.invoice_date>GETDATE() THEN GETDATE()
					ELSE x.invoice_date END AS invoice_date,
					CASE 
						WHEN x.unit_price<=0 THEN c.unit_price
					ELSE ABS(x.unit_price) END AS unit_price,
					x.customer_id as customer_id,
					TRIM(x.country) as country
				FROM prepared AS x
				INNER JOIN unit_price as c
				ON x.stock_key=c.stock_key
				WHERE c.row_number3 =1 )
				INSERT INTO silver.onlineretail(
				invoice_key,
				stock_key,
				product_name,
				quantity,
				invoice_date,
				unit_price,
				customer_id,
				country
				)
				SELECT * FROM final_silver_table;




					
			SET @batch_end_time=GETDATE();
			SET @end_time=GETDATE();
			PRINT '===========================================================================================';
			PRINT '>> Loading Duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds.'
			PRINT '===========================================================================================';
			-- Calculaating Silver Layer Duration Time.
			PRINT '===========================================================================================';
			PRINT 'Loading Silver Layer is Completed.';
			PRINT 'TOTAL DURATION OF LOADING : ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as NVARCHAR)+ ' seconds.';
			PRINT '===========================================================================================';
	END TRY
	--Error handling
	BEGIN CATCH
			PRINT '===========================================================================================';
			
			PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
			PRINT 'ERROR MESSAGE'+ ERROR_MESSAGE();
			PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
			PRINT 'ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR);

			PRINT '===========================================================================================';
	 END CATCH
END;


			PRINT '===========================================================================================';
	 END CATCH
END;

exec silver.load_silver
