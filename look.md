# Online Retail Data Warehouse — SQL Server

Three-layer SQL Server ELT project using the Online Retail CSV:

```text
CSV → bronze.online_retail → silver.online_retail → gold dimensions + fact
```

## Source

`C:\Users\ABDULKHOFIZ\OneDrive - unime.it\Desktop\Online_Retail\Online Retail.csv`

The Bronze load uses SQL Server `BULK INSERT` with CSV parsing. The SQL Server Database Engine service account must be able to read this file. If SQL Server cannot access a Desktop/OneDrive location, copy the CSV to a folder accessible to that service account and update the path in `sql/02_load_bronze.sql`.

## Run order

1. Create an empty SQL Server database named `OnlineRetailDW` in SSMS.
2. Run `sql/01_create_layers.sql` in that database.
3. Run `sql/02_load_bronze.sql` to load the CSV.
4. Run `sql/03_load_silver.sql` to clean and deduplicate the source rows.
5. Run `sql/04_load_gold.sql` to build the analytical star schema.
6. Run `sql/05_data_quality_and_analysis.sql` to review quality and sample analytics.

## Layer rules

- **Bronze:** source-shaped text columns, no business transformations. Reload is a full refresh.
- **Silver:** columns are `invoice_key`, `stock_key`, `product_name`, `quantity`, `unit_price`, `invoice_date`, `customer_id`, and `country`. `invoice_date` is `DATE`; numeric fields use numeric types. Trimming, safe parsing, exact duplicate removal, description fill by `stock_key`, and invalid-row filtering happen here. Missing customer IDs remain `NULL` because the source does not identify those customers; blank country becomes `Unknown`. Returns (negative quantity) and cancelled invoices are retained.
- **Gold:** a star schema with date, product, customer, and country dimensions and a sales fact. `transaction_type` labels sales, returns, and cancelled invoices so analysts can include or exclude them explicitly.

The scripts are full-refresh ELT scripts and can be rerun in order. The source has invoice timestamps, but the requested Silver `DATE` column intentionally drops the time-of-day detail.
