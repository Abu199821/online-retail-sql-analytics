/*
==============================================================================
Quality Checks Script : Silver Layer
==============================================================================
Script Purpose:
    This script performs data quality checks on the Silver Layer table
    'silver.onlineretail' to validate data consistency, uniqueness,
    standardization, and data integrity after cleaning and transformation.

    The following checks are performed:
    1. Duplicate Check
    2. NULL Value Check
    3. Unwanted Spaces Check
    4. Data Type Validation
    5. Invalid Date and Price Check
    6. Data Consistency Check

Note:
    This script validates the quality of transformed data.
    It does not modify the data.

==============================================================================
*/


-----------------------------
-- Checking Duplicates 
-----------------------------

-- Checking duplicates with two columns together reason of 
-- one Incoice might have more items and one item might be sold more than one time.
-- Hence, possibility of existing one Invoice with the same Items might repeate more than one time.
-- Expectation : No Result
SELECT 
	Invoice_key,
	Stock_key,
	COUNT(*) AS Duplicates
FROM bronze.onlineretail
GROUP BY Invoice_key,
		 Stock_key
HAVING COUNT(*)>1


-- Checking for Unwanted Spaces product_name,country
-- Expectation: No Result
-----------------------------------------------------
SELECT
	product_name
FROM bronze.onlineretail 
WHERE product_name!=TRIM(product_name);
-----------------------------------------------------
SELECT
	country
FROM bronze.onlineretail 
WHERE country!=TRIM(country);
-----------------------------------------------------


-- Checking NULL values 
-- Expected result: No Reuslt
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




-- 689 NULL values for product_name
-- 135080 NULL values for customer_id

SELECT 
COUNT(*) NULLS
FROM silver.onlineretail
where customer_id is null

--product_name null checking 

SELECT * FROM silver.onlineretail
WHERE stock_key in (SELECT * FROM silver.onlineretail WHERE product_name is null) and product_name is not null;
-- checking negative quanitites and prices
-- NEGATIVE_QUANTITIES  - 10624
-- NEGATIVE_PRICES - 2
-- ZERO_PRICES - 2519

SELECT 
SUM(CASE WHEN quantity<0 then 1 ELSE 0 END ) AS negative_quantities,
SUM(CASE WHEN quantity=0 THEN 1 ELSE 0 END) AS zero_quantities,
SUM(CASE WHEN unit_price<0 THEN 1 ELSE 0 END) AS negative_prices,
SUM(CASE WHEN unit_price=0 THEN 1 ELSE 0 END) AS zero_prices
FROM silver.onlineretail


-- checking null values that is possible to recover by another stock_key

SELECT a.stock_key,b.stock_key,a.product_name,b.product_name FROM silver.onlineretail as a
INNER JOIN silver.onlineretail as b
ON a.stock_key=b.stock_key
WHERE a.product_name is null and b.product_name is not null
