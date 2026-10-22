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

				INSERT INTO silver.onlineretail (
				Invoice_key,
				stock_key,
				product_name,
				quantity,
				invoice_date,
				unit_price,
				customer_id,
				country
				)
				WITH CTE AS(
				SELECT *,
					ROW_NUMBER() OVER(PARTITION BY 
												stock_key,
												product_name,
												invoice_key,
												invoice_date,
												quantity,
												unit_price,
												customer_id,
												country
												ORDER BY invoice_date ASC) AS RN
				FROM bronze.onlineretail)
				SELECT 
					TRIM(A.Invoice_key) AS invoice_key,
					TRIM(A.stock_key) AS stock_key,
				    CASE
				    WHEN A.product_name IS NULL OR A.unit_price <= 0
				        THEN COALESCE(B.product_name, A.product_name)
				    ELSE ISNULL(A.product_name,'unavailable')
				END AS product_name,
					CAST(A.invoice_date AS DATE) AS invoice_date,
					CASE 
						WHEN A.quantity<=0 THEN B.quantity
						ELSE A.quantity END AS quantity,
					CASE 
						WHEN A.unit_price<=0 THEN B.unit_price
						ELSE A.unit_price END AS unit_price,
					ISNULL(CAST(A.customer_id AS NVARCHAR),'unavailable') AS customer_id,
					TRIM(A.country) AS country
				FROM CTE AS A
				INNER JOIN( SELECT 
					*,
					ROW_NUMBER() OVER(PARTITION BY 
												stock_key,
												product_name,
												invoice_key,
												invoice_date,
												quantity,
												unit_price,
												customer_id,
												country
												ORDER BY invoice_date ASC) AS  RN
				FROM bronze.onlineretail
				WHERE product_name IS NOT NULL AND  unit_price>0 AND  quantity>0) AS B
				ON A.stock_key = B.stock_key
				AND A.invoice_key = B.invoice_key AND  B.RN=1
				WHERE A.RN=1 ;


					
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

exec silver.load_silver
