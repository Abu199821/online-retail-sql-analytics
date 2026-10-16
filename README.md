# E-Commerce Data Analytics | SQL Server ETL Project

**Status:** In Progress 🚧

An ongoing SQL Server project focused on building an ETL pipeline for the Online Retail dataset. The goal is to ingest source data, clean and validate it, and progressively prepare reliable data for analysis.

> This project is actively being developed. The pipeline, transformations, data-quality rules, and analytical models may change as the work progresses.

## Project Goals

- Build an ETL workflow using Microsoft SQL Server and T-SQL.
- Separate ingestion, transformation, and analytical data into Bronze, Silver, and Gold layers.
- Investigate and handle missing values, duplicate records, inconsistent product descriptions, and unusual prices or quantities.
- Use transactions to control and protect important data modifications.
- Practice SQL techniques used in data engineering and analytics.
- Document the decisions, checks, and limitations of each transformation.

## ETL Workflow

```text
Online Retail source file (CSV)
             |
             v
       Extract / Load
             |
             v
     Bronze Layer
  Source data ingestion
             |
             v
       Transform
             |
             v
      Silver Layer
 Cleaning, standardization,
 validation and deduplication
             |
             v
       Transform
             |
             v
       Gold Layer
 Curated analytical tables
        (planned)
```

### Layer Responsibilities

- **Bronze:** Stores ingested source data with minimal changes.
- **Silver:** Applies cleaning and standardization rules, investigates data-quality issues, and validates transformed records.
- **Gold:** Planned layer for business-ready datasets, metrics, and analytical queries. It is not represented as complete while development is ongoing.

## Dataset

The project uses the **Online Retail** transactional dataset. The source data includes invoice lines, product codes and descriptions, dates, quantities, unit prices, customer identifiers, and countries.

Main columns used in the current scripts include:

| Column | Purpose |
|---|---|
| `invoice_key` | Invoice identifier used in the project |
| `stock_key` | Product/stock code |
| `product_name` | Product description |
| `invoice_date` | Invoice date and time |
| `quantity` | Quantity on an invoice line |
| `unit_price` | Unit price |
| `customer_id` | Customer identifier; may be NULL in source records |
| `country` | Country associated with the transaction |

Source-data issues are investigated before correction. For example, negative quantities may represent returns, zero-priced items may have a valid business explanation, and some missing customer IDs may not be recoverable from the available data.

## Current Progress

- [x] Created the initial Bronze and Silver table structures.
- [x] Loaded the Online Retail source data into the Bronze layer.
- [x] Started Silver-layer data cleaning and standardization.
- [x] Developed initial data-quality checks.
- [x] Investigated duplicate combinations and missing product descriptions.
- [ ] Finalize and document repeatable ETL scripts.
- [ ] Validate all Silver-layer transformations.
- [ ] Complete the Gold layer and analytical models.
- [ ] Add final business questions, metrics, and example outputs.

The checklist reflects current development and will be updated as work is completed.

## Data Quality and Validation

The Silver-layer quality-check script is maintained under:

```text
scripts/silver/quality_checks.sql
```

Current checks include:

- Potential duplicate `(invoice_key, stock_key)` combinations.
- NULL counts by column.
- Leading and trailing whitespace.
- Zero and negative quantities or prices.
- Missing product descriptions and possible recovery candidates.
- Conflicting product descriptions for the same stock code.
- Potential customer-ID recovery candidates.
- Repeated combinations across selected columns.

A matching invoice and stock code is not automatically proof of a duplicate. Likewise, a product description or customer ID should not be copied from another row until the candidate mapping has been validated.

## Transaction Safety

For data-changing ETL steps, transactions can be used to review changes before deciding whether to commit or roll them back.

```sql
-- Start a transaction before a controlled data modification.
BEGIN TRANSACTION;

-- Example only: replace with a reviewed ETL operation.
UPDATE silver.onlineretail
SET product_name = product_name
WHERE 1 = 0;

-- Inspect the affected rows and validate the result before deciding.
-- If the result is correct, run this as the transaction's final action:
-- COMMIT TRANSACTION;

-- If the result is incorrect, run this instead:
-- ROLLBACK TRANSACTION;
```

**Transaction rules:**

- Run `BEGIN TRANSACTION` before the statements that need protection.
- Check the affected-row count and validate the results before committing.
- Use either `COMMIT TRANSACTION` or `ROLLBACK TRANSACTION` to finish the transaction; do not execute both consecutively.
- Execute the final decision in the same SQL Server session and query connection that started the transaction.
- Do not leave a transaction open longer than necessary, because it can hold locks and affect other work.
- A rollback can undo changes in the current uncommitted transaction. It does not reverse a transaction that has already been committed.

The example above intentionally performs no data modification. Replace it only with a reviewed operation before using this pattern in the ETL workflow.

## SQL Skills Practiced

- T-SQL and Microsoft SQL Server
- ETL pipeline design
- Bronze / Silver / Gold data-layer architecture
- Common Table Expressions (CTEs)
- INNER JOIN and self-joins
- `GROUP BY`, `HAVING`, and aggregate functions
- Window functions such as `ROW_NUMBER()`
- Duplicate and NULL analysis
- Data cleaning and standardization
- Transaction control with `BEGIN TRANSACTION`, `COMMIT`, and `ROLLBACK`
- Data-quality validation

## Repository Structure

```text
.
├── scripts/
│   └── silver/
│       └── quality_checks.sql
├── README.md
└── ...
```

The structure will evolve as the Bronze ingestion scripts, Silver transformations, and Gold analytical models are added.

## Running the Current Checks

1. Connect to Microsoft SQL Server using SQL Server Management Studio (SSMS) or a compatible SQL editor.
2. Create or select the project database.
3. Ensure the expected schemas and `silver.onlineretail` table exist.
4. Open `scripts/silver/quality_checks.sql`.
5. Execute the checks and review each result set.
6. Investigate findings before making any data-changing corrections.

The script expects the table and column names shown in the project. Adjust references if your local schema differs.

## Development Principles

- Validate before modifying data.
- Prefer repeatable scripts over undocumented manual changes.
- Keep quality checks separate from transformation scripts where practical.
- Preserve source data and document transformation decisions.
- Treat unusual values in business context rather than automatically deleting them.
- Use transactions carefully for important changes.
- Update this README as the pipeline evolves.

## Author

**Abdulkhofiz Jurayev**

SQL Server · ELT · Data Cleaning · Data Analytics

---

*This repository is a work in progress and is intended to demonstrate the development of a practical SQL Server ELT and analytics workflow.*
