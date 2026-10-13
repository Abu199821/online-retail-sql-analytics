--===========================================================================
--						LOADING SILVER LAYER
--						TABLE : silver.onlineretail
--						ELT
--===========================================================================
-- Creating Store Procedure 
CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN 
	BEGIN TRY 
				PRINT '>>======================================================================';
				PRINT 'LOADING DATA TO SILVER LAYER '
				PRINT '>>======================================================================';

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
			SELECT 
			Invoice_key,
			stock_key,
			product_name,
			quantity,
			invoice_date,
			unit_price,
			customer_id,
			country
			FROM bronze.onlineretail;

			SET @batch_end_time=GETDATE();
			SET @end_time=GETDATE();
			PRINT '===========================================================================================';
			PRINT '>> Loading Duration : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds.'
			PRINT '===========================================================================================';
			-- Calculaating Silver Layer Duration Time.
			PRINT '>>=========================================================';
			PRINT 'Loading Silver Layer is Completed.';
			PRINT 'TOTAL DURATION OF LOADING : ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as NVARCHAR)+ ' seconds.';
			PRINT '>>=========================================================';
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
