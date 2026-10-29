# Data Dictionary

This dictionary describes the tables created by `sql/01_create_layers.sql` and populated by the load scripts. `PK` means primary key, `FK` means foreign key, and `UQ` means unique constraint.

## Bronze

### `bronze.online_retail`

Raw staging table. Source values are stored as text before validation and conversion.

| Column | SQL type | Meaning |
|---|---|---|
| `InvoiceNo` | `nvarchar(100)` | Source invoice or transaction identifier. Cancellation identifiers commonly begin with `C`. |
| `StockCode` | `nvarchar(100)` | Source product/stock identifier. |
| `Description` | `nvarchar(1000)` | Source product description. |
| `Quantity` | `nvarchar(100)` | Source line quantity, staged as text. |
| `InvoiceDate` | `nvarchar(100)` | Source transaction date/time, staged as text. |
| `UnitPrice` | `nvarchar(100)` | Source unit price, staged as text. |
| `CustomerID` | `nvarchar(100)` | Source customer identifier; may be blank or invalid. |
| `Country` | `nvarchar(200)` | Source country text. |

## Silver

### `silver.online_retail`

Cleaned, typed transaction-line table. The Silver grain is one deduplicated combination of invoice, stock, product description, quantity, unit price, calendar date, customer, and country.

| Column | SQL type | Meaning |
|---|---|---|
| `invoice_key` | `nvarchar(100)` | Normalized invoice/transaction identifier. |
| `stock_key` | `nvarchar(100)` | Normalized stock/product identifier. |
| `product_name` | `nvarchar(1000)` | Cleaned description; missing descriptions are filled from a stock-code description where possible, otherwise `Unknown`. |
| `quantity` | `int` | Units on the transaction line. Negative values are retained and can indicate returns. |
| `unit_price` | `decimal(18,4)` | Converted unit price. Values below zero are excluded by the Silver load; zero is allowed. |
| `invoice_date` | `date` | Calendar date derived from the source timestamp. Time-of-day is discarded. |
| `customer_id` | `int`, nullable | Converted source customer identifier. Missing/invalid IDs remain `NULL`. |
| `country` | `nvarchar(200)` | Trimmed country; blank values become `Unknown`. |

## Gold dimensions

### `gold.dim_date`

| Column | SQL type | Key | Meaning |
|---|---|---|---|
| `date_key` | `int` | PK | Date key in `YYYYMMDD` form. |
| `full_date` | `date` | UQ | Calendar date. |
| `year` | `smallint` | | Calendar year. |
| `quarter` | `tinyint` | | Calendar quarter, 1–4. |
| `month_number` | `tinyint` | | Calendar month, 1–12. |
| `month_name` | `nvarchar(20)` | | Month name, dependent on SQL Server session language. |
| `day_of_month` | `tinyint` | | Day number within the month. |
| `day_name` | `nvarchar(20)` | | Weekday name, dependent on SQL Server session language. |
| `is_weekend` | `bit` | | 1 for weekend, otherwise 0. |

### `gold.dim_product`

| Column | SQL type | Key | Meaning |
|---|---|---|---|
| `product_key` | `int IDENTITY` | PK | Warehouse-generated product key. |
| `stock_key` | `nvarchar(100)` | UQ | Business identifier from Silver. |
| `product_name` | `nvarchar(1000)` | | Selected product description for the stock key. |

### `gold.dim_customer`

| Column | SQL type | Key | Meaning |
|---|---|---|---|
| `customer_key` | `int IDENTITY` | PK | Warehouse-generated customer key used by the fact table. |
| `customer_id` | `int`, nullable | UQ | Source customer identifier. The special unknown member uses `NULL` and `is_unknown = 1`. |
| `is_unknown` | `bit` | | Marks the unknown customer row. |

### `gold.dim_country`

| Column | SQL type | Key | Meaning |
|---|---|---|---|
| `country_key` | `int IDENTITY` | PK | Warehouse-generated country key. |
| `country` | `nvarchar(200)` | UQ | Country label from Silver, including `Unknown` where applicable. |

## Gold fact

### `gold.fact_sales`

One row per retained Silver transaction line loaded into Gold.

| Column | SQL type | Key | Meaning |
|---|---|---|---|
| `sales_key` | `bigint IDENTITY` | PK | Warehouse-generated fact-row key. |
| `invoice_key` | `nvarchar(100)` | | Source invoice/transaction identifier. |
| `date_key` | `int` | FK → `dim_date.date_key` | Transaction calendar date. |
| `product_key` | `int` | FK → `dim_product.product_key` | Product dimension row. |
| `customer_key` | `int` | FK → `dim_customer.customer_key` | Customer dimension row; missing source customers map to the unknown member. |
| `country_key` | `int` | FK → `dim_country.country_key` | Country dimension row. |
| `transaction_type` | `varchar(20)` | | `SALE`, `RETURN`, or `CANCELLED`, derived by the Gold load. |
| `quantity` | `int` | | Transaction-line quantity, including negative return quantities. |
| `unit_price` | `decimal(18,4)` | | Silver unit price. |
| `sales_amount` | `decimal(19,4)` | | `quantity * unit_price`; can be negative for returns or zero for zero-price rows. |

## Key relationships

```text
gold.dim_date.date_key       1 ─── * gold.fact_sales.date_key
gold.dim_product.product_key 1 ─── * gold.fact_sales.product_key
gold.dim_customer.customer_key 1 ─ * gold.fact_sales.customer_key
gold.dim_country.country_key 1 ─── * gold.fact_sales.country_key
```

