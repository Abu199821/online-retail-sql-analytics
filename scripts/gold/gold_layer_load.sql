/*
    Project:    Online Retail SQL Analytics
    Author:     ABDULHAFIZ JURAEV
    Procedure:  gold.load_gold

    Purpose:
        Reload the Gold layer from the Silver layer for analytics
        using batch processing.

    Processing approach:
        1. Delete existing rows from gold.fact_sales first, followed by
           the dimension tables, to respect foreign key relationships.
        2. Use DELETE instead of DROP so table structures, primary keys,
           and foreign key constraints remain in place.
        3. Reload the product, customer, and date dimensions from Silver.
        4. Reload gold.fact_sales using the keys generated in the dimensions.

    Usage:
        EXEC gold.load_gold;
*/

CREATE OR ALTER PROCEDURE gold.load_gold
AS
BEGIN
	
    DECLARE
        @batch_start_time DATETIME = GETDATE(),
        @start_time       DATETIME,
        @end_time         DATETIME;

    BEGIN TRY
        BEGIN TRANSACTION;

        PRINT 'Gold layer loading started.';

        -- Cleaning Fact table
        DELETE FROM gold.fact_sales;

        -- After being fact table empty , dimension tables will ber cleaned .
        DELETE FROM gold.dim_product;
        DELETE FROM gold.dim_customer;
        DELETE FROM gold.dim_date;
		-- Customer dimension: NULLs in customer id will be replaced with -1.
        
        SET @start_time = GETDATE();

       ;WITH customer_cte AS
		(
			SELECT
				COALESCE(customer_id, -1) AS customer_id,
				country,
				ROW_NUMBER() OVER (
					PARTITION BY COALESCE(customer_id, -1)
					ORDER BY CASE WHEN country IS NOT NULL THEN 0 ELSE 1 END, country
				) AS rn
			FROM silver.onlineretail
		)
		INSERT INTO gold.dim_customer (customer_id, country)
		SELECT customer_id, country
		FROM customer_cte
		WHERE rn = 1;


        SET @end_time = GETDATE();
        PRINT 'dim_product loaded in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';

      -- Product dimension: One row for every stock_key
        SET @start_time = GETDATE();

		;WITH product_cte AS
		(
			SELECT
				stock_key,
				product_name,
				ROW_NUMBER() OVER (
					PARTITION BY stock_key
					ORDER BY CASE WHEN product_name IS NOT NULL THEN 0 ELSE 1 END,
							 product_name
				) AS rn
			FROM silver.onlineretail
			WHERE stock_key IS NOT NULL
		)
		INSERT INTO gold.dim_product (stock_key, product_name)
		SELECT stock_key, product_name
		FROM product_cte
		WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT 'dim_customer loaded in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';

        -- Date dimension: Full date will not save time part .
        SET @start_time = GETDATE();

        ;WITH distinct_dates AS
        (
            SELECT DISTINCT CAST(invoice_date AS DATE) AS full_date
            FROM silver.onlineretail
            WHERE invoice_date IS NOT NULL
        )
        INSERT INTO gold.dim_date
        (
            date_key,
            full_date,
            day_number,
            month_number,
            month_name,
            quarter_number,
            year_number
        )
        SELECT
            CONVERT(INT, CONVERT(CHAR(8), full_date, 112)) AS date_key,
            full_date,
            DAY(full_date),
            MONTH(full_date),
            DATENAME(MONTH, full_date),
            DATEPART(QUARTER, full_date),
            YEAR(full_date)
        FROM distinct_dates;

        SET @end_time = GETDATE();
        PRINT 'dim_date loaded in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';

        -- Fact: All dimenstion keys inserted from dimenstion tables.
        SET @start_time = GETDATE();

        INSERT INTO gold.fact_sales
        (
            invoice_key,
            product_key,
            customer_key,
            date_key,
            quantity,
            unit_price,
            total_amount
        )
        SELECT
            a.invoice_key,
            b.product_key,
            d.customer_key,
            c.date_key,
            a.quantity,
            a.unit_price,
            a.quantity * a.unit_price
        FROM silver.onlineretail AS a
        INNER JOIN gold.dim_product AS b
            ON a.stock_key = b.stock_key
        INNER JOIN gold.dim_date AS c
            ON CAST(a.invoice_date AS DATE) = c.full_date
        INNER JOIN gold.dim_customer AS d
            ON COALESCE(a.customer_id, -1) = d.customer_id;

        SET @end_time = GETDATE();
        PRINT 'fact_sales loaded in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';

        COMMIT TRANSACTION;

        PRINT 'Gold layer loading completed in '
            + CAST(DATEDIFF(SECOND, @batch_start_time, GETDATE()) AS NVARCHAR(20))
            + ' seconds.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        PRINT 'Gold layer loading failed.';
        PRINT ERROR_MESSAGE();

        THROW;
    END CATCH
END;
GO





