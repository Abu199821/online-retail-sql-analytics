# Project Documentation

## Online Retail SQL Analytics

**Author:** ABDULKHOFIZ JURAEV  
**Platform:** Microsoft SQL Server (T-SQL)

## 1. Project purpose

This project transforms the Online Retail CSV dataset into a SQL Server data warehouse that can support consistent reporting and exploratory analysis. It uses a three-layer medallion-style architecture: Bronze stages source data, Silver cleans and standardizes it, and Gold organizes it into a star schema.

## 2. Architecture

```text
Online Retail.csv
        |
        v
Bronze: bronze.online_retail
        |
        v
Silver: silver.online_retail
        |
        v
Gold: dim_date, dim_product, dim_customer, dim_country, fact_sales
```

The architecture image is available at [etl_architecture.jpg](images/online_retail_etl_architecture.jpg). The Gold relationship diagram is available at [gold_star_schema.jpg](images/gold_star_schema.jpg).

## 3. SQL scripts

| Script | Purpose |
|---|---|
| `sql/01_create_layers.sql` | Creates the Bronze, Silver, and Gold schemas and tables if they do not already exist. |
| `sql/02_load_bronze.sql` | Clears and reloads the Bronze table from the source CSV using `BULK INSERT`. |
| `sql/03_load_silver.sql` | Converts types, cleans text and values, fills product descriptions where possible, and deduplicates into Silver. |
| `sql/04_load_gold.sql` | Rebuilds Gold dimensions and the sales fact table from Silver inside a transaction. |
| `sql/05_data_quality_and_analysis.sql` | Provides row-count and data-quality checks plus example sales analysis queries. |

## 4. Setup and execution

1. Create or select the target SQL Server database in SSMS.
2. Run `sql/01_create_layers.sql` in that database.
3. Edit the CSV path in `sql/02_load_bronze.sql` so it points to the local `Online Retail.csv` file. The SQL Server Database Engine service account needs read access to the file.
4. Run the load scripts in order: `02_load_bronze.sql`, `03_load_silver.sql`, then `04_load_gold.sql`.
5. Run `05_data_quality_and_analysis.sql` to check the results.

The Bronze loader uses SQL Server CSV bulk-load syntax. Use a SQL Server version that supports `BULK INSERT ... FORMAT = 'CSV'` and ensure the service account can access the CSV location.

## 5. Layer behavior

### Bronze

`bronze.online_retail` stores the eight source fields as text. This preserves source values until the Silver transformation. The Bronze load is a full refresh: it truncates the staging table and bulk loads the CSV again.

### Silver

`silver.online_retail` contains typed transaction rows. The load trims text, safely converts numeric/date values, replaces blank country with `Unknown`, fills missing product descriptions from the most frequent description for the same stock key where possible, and removes duplicate rows at the Silver business grain. Invoice timestamps are converted to `DATE`, so time-of-day is not retained in Silver. Missing customer IDs remain `NULL`. Negative quantities and cancelled invoice identifiers are retained.

### Gold

Gold is a dimensional star schema. `gold.fact_sales` is the transaction-line fact table, linked to date, product, customer, and country dimensions. The Gold script deletes fact rows before dimension rows, then rebuilds dimensions and fact data from Silver. It uses `DELETE` to preserve table definitions and foreign-key constraints. The load runs in a transaction and rolls back on failure.

## 6. Reloading

The pipeline is designed for full snapshot reloads. Run the scripts in Bronze → Silver → Gold order. Re-running the loaders replaces the previous layer contents with the current upstream snapshot; it is not an incremental change-data-capture pipeline.

## 7. Related documentation

- [Data Dictionary](data_dictionary.md) — table and column definitions.
- [Analytics Notes](analytics_notes.md) — transaction categories, metric definitions, and interpretation caveats.
