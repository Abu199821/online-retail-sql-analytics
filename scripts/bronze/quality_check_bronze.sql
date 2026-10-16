/*
==============================================================================
Quality Checks Script : Bronze Layer
==============================================================================
Script Purpose:
    This script performs basic validation checks on the Bronze Layer
    table 'bronze.onlineretail' after loading data from the source CSV file.

    The following checks are performed:
    1. Row Count Check: Verifies the total number of records loaded.

    2. Data Preview: Displays sample records to verify the loaded data.

    3. Null values checking throught all columns 

Note:
    This script validates data ingestion only.
    No data cleaning or transformation is performed.

==============================================================================
*/

--Row Count Check:Verifies the total number of records loaded.( Checking row numbers with expected quantity )
SELECT count(*) as Row_Numver FROM bronze.onlineretail;


 --Data Preview: Displays sample records to verify the loaded data.

SELECT TOP 100 * FROM bronze.onlineretail;


-- Null values checking throught all columns 

SELECT
    SUM(CASE WHEN invoice_key IS NULL THEN 1 ELSE 0 END) AS null_invoice_key,
    SUM(CASE WHEN stock_key IS NULL THEN 1 ELSE 0 END) AS null_stock_key,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS null_invoice_date,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country
FROM bronze.onlineretail;
