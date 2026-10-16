# E-Commerce Data Analytics | SQL Server

An end-to-end SQL Server analytics project built around the Online Retail dataset. The project demonstrates a layered data pipeline, data cleaning, quality validation, and analytical SQL techniques.

> **Project status:** In progress — pipeline and data-quality checks are being developed iteratively.

## Project Overview

This project explores retail transaction data to prepare a reliable dataset for analysis. It uses a layered architecture to separate raw ingestion, data cleaning, and business-ready data.

### Objectives

- Build a structured data pipeline in SQL Server.
- Organize data into Bronze, Silver, and Gold layers.
- Clean and standardize retail transaction data.
- Identify duplicate records, missing values, and inconsistent product details.
- Apply SQL techniques such as CTEs, joins, window functions, and aggregations.
- Prepare a foundation for reporting and business analysis.

## Architecture

```text
Online Retail CSV
      |
      v
Bronze Layer  ->  Raw/staged source data
      |
      v
Silver Layer  ->  Cleaned and validated data
      |
      v
Gold Layer    ->  Business-ready models and analytics
```

- **Bronze:** Loads source data with minimal transformation.
- **Silver:** Cleans, standardizes, and validates records.
- **Gold:** Intended for curated analytical tables, metrics, and reporting.

## Dataset

The project uses the **Online Retail** transactional dataset. It contains retail invoice lines and fields such as:

| Column | Description |
|---|---|
| `invoice_key` | Invoice identifier used in the project |
| `stock_key` | Product/stock code |
| `product_name` | Product description |
| `invoice_date` | Invoice date and time |
| `quantity` | Quantity purchased; negative values may represent returns |
| `unit_price` | Unit price |
| `customer_id` | Customer identifier, which may be missing in source records |
| `country` | Customer country |

The source dataset may contain missing values, returns, zero-priced items, and repeated invoice/product combinations. These require investigation rather than blindly deleting or replacing records.

## Data Quality Checks

The Silver-layer quality-check script is located at:

```text
scripts/silver/quality_checks.sql
```

It includes read-only checks for:

1. Potential duplicate `(invoice_key, stock_key)` combinations.
2. NULL counts by column.
3. Leading and trailing whitespace.
4. Zero and negative quantities or prices.
5. Missing product names and possible recovery candidates.
6. Multiple product names associated with the same stock key.
7. Potential customer ID recovery candidates within an invoice.
8. Repeated combinations across the selected data columns.

**Important:** These checks report findings; they do not update or delete data. A repeated invoice/product pair is not automatically a confirmed duplicate. Validate the business meaning before removing rows. Similarly, candidate product names and customer IDs should be reviewed before applying corrections.

## SQL Skills Demonstrated

- T-SQL and SQL Server
- CTEs (`WITH`)
- Joins and self-joins
- `GROUP BY` and `HAVING`
- Window functions, including `ROW_NUMBER()`
- Duplicate and NULL analysis
- Data standardization and validation
- Transaction safety concepts (`BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`)
- Analytical aggregations

## Repository Structure

```text
.
├── scripts/
│   └── silver/
│       └── quality_checks.sql
├── README.md
└── ...
```

The repository structure may expand as the Bronze ingestion process, Silver transformations, and Gold analytical models are added.

## How to Run

1. Install or connect to Microsoft SQL Server.
2. Open the scripts in SQL Server Management Studio (SSMS) or another compatible SQL editor.
3. Create or restore the project database and load the source dataset into the expected schema.
4. Ensure `silver.onlineretail` exists and its column names match those used in the script.
5. Run `scripts/silver/quality_checks.sql`.
6. Review the result sets and investigate findings before making changes.

> The quality-check script expects a table named `silver.onlineretail`. Update the table or column references if your local schema differs.

## Data Handling Notes

- Negative quantities can represent returns and should not be automatically treated as invalid.
- Zero or negative prices require investigation in context.
- NULL customer IDs may be present in the original dataset and may not always be recoverable.
- Product names should not be copied between rows solely because their stock codes match; first confirm that the candidate mapping is consistent.
- Always validate the affected rows before running destructive statements. Use transactions carefully and finish open transactions with either `COMMIT` or `ROLLBACK`.

## Roadmap

- [x] Create Bronze and Silver data structures
- [x] Develop initial Silver-layer quality checks
- [ ] Finalize repeatable Bronze ingestion
- [ ] Document and automate Silver transformations
- [ ] Build Gold-layer analytical models
- [ ] Add business questions and KPI queries
- [ ] Add sample results and documentation

## Author

**Abdulkhofiz Jurayev**

SQL Server • Data Analytics • Data Cleaning • ETL

---

This project is intended as a learning and portfolio project demonstrating practical SQL data engineering and analytics workflows.
