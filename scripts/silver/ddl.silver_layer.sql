

USE ECommerceAnalytics;
GO


CREATE SCHEMA silver;
GO


IF  OBJECT_ID('silver.onlineretail','U') IS NOT NULL
	DROP TABLE silver.onlineretail;
GO

CREATE TABLE silver.onlineretail (
    invoice_key NVARCHAR(50),
    stock_key NVARCHAR(50),
    product_name NVARCHAR(200),
    quantity INT,
    invoice_date DATETIME2,
    unit_price DECIMAL(10,2),
    customer_id INT,
    country NVARCHAR(50)
);
GO
