
/*
===============================================================================
Query Purpose: Create Gold Layer Tables
===============================================================================
Description:
    This stored procedure creates the Gold layer tables for the Online Retail
    Data Warehouse using a Star Schema architecture.

    It creates the following tables:
        1. gold.dim_product  - Product dimension
        2. gold.dim_customer - Customer dimension
        3. gold.dim_date     - Date dimension
        4. gold.fact_sales   - Sales fact table

    The procedure drops existing tables and recreates them with the required
    primary key and foreign key constraints.

Warning:
    Executing this procedure deletes existing data in these tables.

Usage:
    EXEC gold.create_tables;

===============================================================================
*/




CREATE OR ALTER PROCEDURE gold.create_tables
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '******************';
    PRINT 'CREATE TABLES';
    PRINT '******************';

    IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
        DROP TABLE gold.fact_sales;

    IF OBJECT_ID('gold.dim_product', 'U') IS NOT NULL
        DROP TABLE gold.dim_product;

    IF OBJECT_ID('gold.dim_customer', 'U') IS NOT NULL
        DROP TABLE gold.dim_customer;

    IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
        DROP TABLE gold.dim_date;

    CREATE TABLE gold.dim_product (
        product_key INT IDENTITY(1,1) PRIMARY KEY,
        stock_key NVARCHAR(50),
        product_name NVARCHAR(200)
    );

    PRINT '>> gold.dim_product created.';

    CREATE TABLE gold.dim_customer (
        customer_key INT IDENTITY(1,1) PRIMARY KEY,
        customer_id NVARCHAR(50),
        country NVARCHAR(100)
    );

    PRINT '>> gold.dim_customer created.';

    CREATE TABLE gold.dim_date (
        date_key INT PRIMARY KEY,
        full_date DATE,
        day_number INT,
        month_number INT,
        month_name NVARCHAR(20),
        quarter_number INT,
        year_number INT
    );

    PRINT '>> gold.dim_date created.';

    CREATE TABLE gold.fact_sales (
        sales_key BIGINT IDENTITY(1,1) PRIMARY KEY,
        invoice_key NVARCHAR(50),
        product_key INT,
        customer_key INT,
        date_key INT,
        quantity INT,
        unit_price DECIMAL(10,2),
        total_amount DECIMAL(20,2),

        CONSTRAINT FK_fact_sales_product
            FOREIGN KEY (product_key)
            REFERENCES gold.dim_product(product_key),

        CONSTRAINT FK_fact_sales_customer
            FOREIGN KEY (customer_key)
            REFERENCES gold.dim_customer(customer_key),

        CONSTRAINT FK_fact_sales_date
            FOREIGN KEY (date_key)
            REFERENCES gold.dim_date(date_key)
    );

    PRINT '>> gold.fact_sales created.';
END;








