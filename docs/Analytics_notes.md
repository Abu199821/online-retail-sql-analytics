# Analytics Notes

These notes define how to interpret the Gold data and the example queries in `sql/05_data_quality_and_analysis.sql`.

## Transaction categories

The Gold load assigns each fact row a `transaction_type` using this order:

1. `CANCELLED` — `invoice_key` begins with `C` (case-insensitive).
2. `RETURN` — quantity is negative and the invoice is not classified as cancelled.
3. `SALE` — all remaining rows.

The cancellation check takes precedence over the negative-quantity check. Returns and cancellations remain in the fact table so analysts can include or exclude them explicitly.

## Measure definitions

- **Sales revenue:** sum `gold.fact_sales.sales_amount` where `transaction_type = 'SALE'`.
- **Sales orders:** distinct count of `invoice_key` where `transaction_type = 'SALE'`.
- **Units sold:** sum `quantity` where `transaction_type = 'SALE'`.
- **Return amount:** sum `sales_amount` where `transaction_type = 'RETURN'`. It may be negative or zero, depending on quantity and unit price.
- **Net sales after returns:** sales revenue plus return amount. Decide separately whether cancelled invoices should affect any business KPI; the example sales revenue excludes them.
- **Average order value:** sales revenue divided by distinct sales invoices. Guard against a zero denominator.

Example monthly sales query:

```sql
SELECT d.[year], d.month_number, d.month_name,
       SUM(f.sales_amount) AS sales_revenue
FROM gold.fact_sales AS f
JOIN gold.dim_date AS d ON d.date_key = f.date_key
WHERE f.transaction_type = 'SALE'
GROUP BY d.[year], d.month_number, d.month_name
ORDER BY d.[year], d.month_number;
```

## Data handling rules and caveats

- **Customer IDs:** Silver preserves missing customer IDs as `NULL`. Gold maps those fact rows to the single unknown row in `dim_customer` (`is_unknown = 1`). Exclude the unknown member from customer counts and rankings unless measuring unknown-customer activity.
- **Country:** blank Silver country values are replaced with `Unknown`, then represented in `dim_country`.
- **Returns:** negative quantities are retained. Do not count them as normal sales units or sales revenue; analyze them separately with `transaction_type = 'RETURN'`.
- **Cancellations:** invoice identifiers beginning with `C` are classified as cancellations. Exclude them from sales KPIs unless a metric explicitly includes cancelled activity.
- **Zero prices:** Silver permits a unit price of zero. Therefore, a return line may have zero `sales_amount`; this does not mean the return line was lost.
- **Date grain:** Silver stores `invoice_date` as `DATE`; time-of-day is discarded. Gold date analysis is at calendar-day grain.
- **Deduplication:** Silver removes exact duplicates at its declared business grain. Repeated invoice/product rows that differ in quantity, price, date, customer, or country remain separate transaction lines.
- **Currency:** the source file does not provide currency metadata. Do not assign a currency symbol without confirming the dataset's currency.
- **Month and weekday names:** `DATENAME` output depends on the SQL Server session language. Set the session language if consistent English or localized names are required.
- **Full refresh:** loaders replace the prior layer snapshot. Compare results only after running the complete Bronze → Silver → Gold sequence.

## Suggested checks before reporting

1. Confirm row counts for Bronze, Silver, and `gold.fact_sales`.
2. Review Silver invalid-row and duplicate checks in `sql/05_data_quality_and_analysis.sql`.
3. Compare fact transaction counts and amounts by `transaction_type`.
4. Check for zero-price return lines before interpreting return value totals.
5. Validate the date range and top-product results against the loaded snapshot.

