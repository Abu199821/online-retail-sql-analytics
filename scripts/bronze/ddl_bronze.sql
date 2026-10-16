
/*
==============================================================================
DDL Script : Create Bronze Tables
==============================================================================
Script Purpose:
	This script creates tables in the 'bronze' schema,dropping existing tables
	if they already exist.
	Run this script to re-define the DDL structure of 'bronze' Tables.
==============================================================================

*/




	IF OBJECT_ID('bronze.onlineretail','U') IS NOT NULL
		DROP TABLE bronze.onlineretail;


	CREATE TABLE bronze.onlineretail(
	Invoice_key NVARCHAR(50),
	stock_key NVARCHAR(50),
	product_name NVARCHAR(200),
	quantity INT,
	invoice_date  VARCHAR(50),
	unit_price DECIMAL(10,2),
	customer_id INT,
	country NVARCHAR(50)
	);
