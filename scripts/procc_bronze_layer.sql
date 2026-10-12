/*
========================================================================================
Stored Procedure: Load Bronze Layer ( Source -> Bronze)
========================================================================================
Script Purpose : 
      This stored procedure loads data into the 'bronze' schema from external CSV files.
      It performs the following actions:
      - Truncates the bonze tables before loading data.
      - Uses the 'BULK INSERT' command to load data from csv Files to bronze tables.
Parameters:
      None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
      EXEC bronze.load_bronze;
========================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	BEGIN TRY
		
		DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;

		SET @batch_start_time=GETDATE();
		PRINT '========================================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '========================================================================================';


		PRINT '========================================================================================';
		PRINT 'Loading onlineretail table';
		PRINT '========================================================================================';

		SET @start_time=GETDATE();
		PRINT '>> Truncate Table : bronze.onlineretail';
		TRUNCATE TABLE bronze.onlineretail;
		PRINT '>> Inserting Data Into : bronze.onlineretail';

		BULK INSERT bronze.onlineretail
	
		FROM 'D:\SQL_Project\Online Retail.csv'
		WITH
		(
			FORMAT = 'CSV',
			FIRSTROW = 2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001'
		);

		SET @end_time=GETDATE();
		PRINT '>> Loading Duration :'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + ' seconds.';
		PRINT '>> --------------------------------------------------------';

		SET @batch_end_time=GETDATE();
		PRINT '=============================================================================================='
		PRINT 'Loading Bronze Layer is Completed ';
		PRINT '>> Total Load Duration : ' +CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR )+ ' seconds.';
		PRINT '=============================================================================================='

	END TRY
	BEGIN CATCH

		PRINT '==============================================================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==============================================================================================';

	END CATCH
END;
