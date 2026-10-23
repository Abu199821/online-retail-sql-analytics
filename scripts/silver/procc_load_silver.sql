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

				
				WITH CTE AS
				( SELECT *, ROW_NUMBER() OVER ( PARTITION BY stock_key,
									                product_name,
									                invoice_key,
									                invoice_date,
									                quantity,
									                unit_price,
									                customer_id,
									                country
				            ORDER BY invoice_date
				        ) AS RN
				FROM bronze.onlineretail
				)
				
				INSERT INTO silver.onlineretail
				(
				    invoice_key,
				    stock_key,
				    product_name,
				    quantity,
				    invoice_date,
				    unit_price,
				    customer_id,
				    country
				)
				
				SELECT
				    TRIM(A.invoice_key) AS invoice_key,
				    TRIM(A.stock_key) AS stock_key,
				    case
				        when A.product_name is null or A.unit_price <= 0
				        then COALESCE(
				                (
				                select TOP 1 B.product_name
				                from bronze.onlineretail as B
				                where B.stock_key = A.stock_key and B.invoice_key = A.invoice_key
				                  and B.product_name is not null and B.unit_price > 0
				                  and B.quantity > 0 order by B.invoice_date ),
				            A.product_name,
				            'unavailable'
				        )
				        else A.product_name
				    end as product_name,
				
				    case
				        when A.quantity <= 0
				        then
				            (
				                select  TOP 1 B.quantity
				                from bronze.onlineretail as B
				                where B.stock_key = A.stock_key  and B.invoice_key = A.invoice_key
				                  and B.product_name is not null  and B.quantity > 0 and B.unit_price > 0
				                order by B.invoice_date
				            )
				        else A.quantity
				    end as quantity,
				
				    CAST(A.invoice_date AS DATE) AS invoice_date,
				    case
				        when A.unit_price <= 0  then
				                (
				                select TOP 1 B.unit_price
				                from bronze.onlineretail as  B
				                where B.stock_key = A.stock_key
				                 and  B.invoice_key = A.invoice_key and  B.product_name is not null
				                  and  B.quantity > 0  and  B.unit_price > 0
				                   order by B.invoice_date
				            )
				        else A.unit_price
				    end as unit_price,
				    customer_id,				
				    TRIM(A.country) as country
				from cte as A
				where A.RN = 1;

					
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
