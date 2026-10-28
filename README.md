# 🏬 Online Retail SQL Analytics

**👤 Author:** ABDULHAFIZ JURAEV  
**📦 Project:** Online Retail SQL Analytics  
**🛠️ Platform:** Microsoft SQL Server · T-SQL

## 🚀 Project overview

This project builds an analytics-ready data warehouse from the Online Retail transaction dataset using SQL Server. SQL scripts load the source CSV into a Bronze layer, clean and standardize records in Silver, and build a dimensional Gold layer for analysis.

The workflow follows a medallion-style ETL/ELT pipeline: raw data is loaded into the database first, then transformed with SQL as it moves through the layers.

```text
🧾 Online Retail CSV
      │
      ▼
🥉 Bronze: bronze.online_retail       Raw source fields
      │
      ▼
🥈 Silver: silver.online_retail       Typed, cleaned, deduplicated rows
      │
      ▼
🥇 Gold: dimensions + fact table      Analytics star schema
      │
      └── 🔎 Data quality checks and sample analysis
```

## 📁 Repository structure

```text
sql/
  01_create_layers.sql              Create schemas and layer tables
  02_load_bronze.sql                Full-refresh CSV load into Bronze
  03_load_silver.sql                Clean and transform Bronze into Silver
  04_load_gold.sql                  Build Gold dimensions and fact table
  05_data_quality_and_analysis.sql  Quality checks and sample analysis
```

## 🧱 Data warehouse model

### 🥉 Bronze layer

`bronze.online_retail` keeps the eight source columns as text so original values can be staged before type conversion and validation.

### 🥈 Silver layer

`silver.online_retail` stores cleaned transaction rows with typed fields: invoice and stock identifiers, product name, quantity, unit price, invoice date, customer ID, and country. The load trims text, safely converts numeric and date values, fills missing product descriptions where possible, labels blank countries as `Unknown`, and removes duplicate business rows. Missing customer IDs remain `NULL`. Negative quantities and cancelled invoices are retained for later classification.

### 🥇 Gold layer

The Gold layer is a star schema:

- 📅 `gold.dim_date` — calendar attributes and date key.
- 🛍️ `gold.dim_product` — one product record per stock key.
- 👥 `gold.dim_customer` — customer identifiers and an unknown-customer member.
- 🌍 `gold.dim_country` — distinct country values.
- 📊 `gold.fact_sales` — transaction line facts, dimension keys, quantity, unit price, and sales amount. `transaction_type` distinguishes `SALE`, `RETURN`, and `CANCELLED` rows.

## ⚙️ Setup and run order

1. Create an empty SQL Server database, for example `OnlineRetailDW`, and connect to it in SSMS.
2. Run `sql/01_create_layers.sql` to create the Bronze, Silver, and Gold schemas and tables.
3. In `sql/02_load_bronze.sql`, update the `BULK INSERT` file path to the location of your CSV. The SQL Server Database Engine service account must have permission to read that file.
4. Run the scripts in order:

   1. `sql/02_load_bronze.sql`
   2. `sql/03_load_silver.sql`
   3. `sql/04_load_gold.sql`
   4. `sql/05_data_quality_and_analysis.sql` for quality checks and example analysis

Run them in the same database where `01_create_layers.sql` was executed.

## 🔄 Reload behavior

The load scripts perform full refreshes. Bronze and Silver are cleared before reloading. The Gold script deletes fact rows before dimension rows to respect foreign-key dependencies, then rebuilds the dimensions and fact data from Silver. It uses `DELETE` so the Gold table definitions and constraints remain in place. Running the load scripts again in order refreshes the layers rather than appending another copy of the same snapshot.

## ✅ Data quality and analysis

`sql/05_data_quality_and_analysis.sql` includes layer row counts, Silver validity and duplicate checks, transaction-type totals, monthly sales, and top-product analysis. Returns and cancellations remain visible in Gold; filter on `transaction_type = 'SALE'` when calculating sales revenue that excludes them.

## 📝 Notes

- The source CSV path in `sql/02_load_bronze.sql` is machine-specific and must be updated for another environment.
- Month and weekday names returned by SQL Server can depend on the session language.
- The source dataset does not specify a currency symbol; avoid claiming a currency unless one is confirmed.
