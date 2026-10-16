/*
===============================================================================
Purpose:
    Perform data quality checks on the Silver layer to validate data
    consistency, completeness, and accuracy before proceeding to the Gold layer.

Target Table:
    silver.onlineretail

Quality Checks:
    - Identify potential duplicate records.
    - Detect NULL and missing values.
    - Check for leading and trailing whitespace.
    - Identify invalid or unusual quantities and prices.
    - Investigate missing product names and potential recovery candidates.
    - Detect conflicting product names associated with the same stock key.
    - Identify potential customer ID recovery candidates.
    - Check for exact duplicate records.

Expected Outcome:
    Identify data quality issues and support reliable, consistent,
    and analytics-ready data for downstream processing.

Note:
    This script is intended for data quality assessment and does not
    modify the underlying data.

===============================================================================
*/
