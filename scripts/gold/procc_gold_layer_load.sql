CREATE OR ALTER PROCEDURE gold.load_gold
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @batch_start_time DATETIME = GETDATE(),
        @start_time       DATETIME,
        @end_time         DATETIME;

    BEGIN TRY
        BEGIN TRANSACTION;

        PRINT 'Gold layer loading started.';

        -- Fact jadvalini avval tozalaymiz.
        DELETE FROM gold.fact_sales;

        -- Dimension jadvallarini fact bo‘shagandan keyin tozalaymiz.
        DELETE FROM gold.dim_product;
        DELETE FROM gold.dim_customer;
        DELETE FROM gold.dim_date;

        -- Product dimension: har bir stock_key uchun bitta qator.
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

        -- Customer dimension: NULL customer_id lar -1 ga aylantiriladi.
        SET @start_time = GETDATE();

        INSERT INTO gold.dim_customer (customer_id)
        SELECT DISTINCT COALESCE(customer_id, -1)
        FROM silver.onlineretail;

        SET @end_time = GETDATE();
        PRINT 'dim_customer loaded in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';

        -- Date dimension: full_date vaqt qismini saqlamaydi.
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

        -- Fact: dimension kalitlari dimension jadvallaridan olinadi.
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
