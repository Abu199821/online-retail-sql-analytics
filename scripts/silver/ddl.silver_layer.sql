/*
===============================================================================
Purpose:
    Initialize the Silver layer by creating the schema and defining the
    target table structure for cleaned and standardized retail data.

Database:
    ECommerceAnalytics

Schema:
    silver

Target Table:
    silver.onlineretail

Implementation:
    - Create the Silver schema if it does not already exist.
    - Drop the existing target table if it exists.
    - Create the target table with appropriate data types for each column.

Note:
    Dropping the existing table permanently removes its data and table-level
    objects. Execute this script with caution.

===============================================================================
*/



CREATE OR ALTER PROCEDURE silver.create_tables AS 
BEGIN
	PRINT '******************'
	PRINT 'CREATE TABLES'
	PRINT '******************'	

	IF  OBJECT_ID('silver.onlineretail','U') IS NOT NULL
		DROP TABLE silver.onlineretail;
	GO

	CREATE TABLE silver.onlineretail (
		invoice_key NVARCHAR(50),
		stock_key NVARCHAR(50),
		product_name NVARCHAR(200),
		quantity INT,
		invoice_date DATE,
		unit_price DECIMAL(10,2),
		customer_id INT,
		country NVARCHAR(50)
	)
END;


