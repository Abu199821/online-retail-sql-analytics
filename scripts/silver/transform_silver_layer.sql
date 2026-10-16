/*
===============================================================================
Purpose:
    Transform and standardize data in the Silver layer to improve data quality
    and prepare the dataset for reliable downstream analytics.

Transformation Scope:
    - Clean and standardize text fields.
    - Handle missing and NULL values where appropriate.
    - Validate quantity and unit price values.
    - Identify and resolve duplicate records when justified.
    - Investigate missing product names and customer IDs.
    - Apply consistent data transformation rules.

Source Table:
    bronze.onlineretail

Target Table:
    silver.onlineretail

ELT Process:
    Data is first loaded into the database and then transformed using SQL.

Expected Outcome:
    Produce a clean, consistent, and analytics-ready dataset for the Gold layer.

Note:
    Data corrections must be based on verified business rules and reliable
    source values. Potential duplicates and missing values should be
    investigated before records are modified or removed.

===============================================================================
*/
