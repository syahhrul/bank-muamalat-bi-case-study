-- PT Sejahtera Bersama / Bank Muamalat x Rakamin BI VIX
-- STEP 1: Create BigQuery tables before loading public, minimized CSVs.
-- Replace PROJECT_ID (all occurrences) with your own Google Cloud project ID.
-- Region: US. Change only if your BigQuery project and datasets use a different location.
--
-- LOAD DATA AFTER THIS SCRIPT:
--   data/raw/Customers.csv       -> customers       (skip 1 header row)
--   data/raw/Products.csv        -> products        (skip 1 header row)
--   data/raw/Orders.csv          -> orders          (skip 1 header row)
--   data/raw/ProductCategory.csv -> product_category (skip 1 header row)
-- Use CSV source, WRITE_TRUNCATE / overwrite destination, explicit schemas below.
-- IMPORTANT: raw order Date is a STRING in DD/MM/YYYY, NOT a BigQuery DATE.

CREATE SCHEMA IF NOT EXISTS `PROJECT_ID.bank_muamalat`
OPTIONS(location = 'US');

CREATE OR REPLACE TABLE `PROJECT_ID.bank_muamalat.customers` (
  CustomerID INT64,
  CustomerCity STRING,
  CustomerState STRING
);

CREATE OR REPLACE TABLE `PROJECT_ID.bank_muamalat.products` (
  ProdNumber STRING,
  ProdName STRING,
  Category INT64,
  Price NUMERIC
);

CREATE OR REPLACE TABLE `PROJECT_ID.bank_muamalat.orders` (
  OrderID INT64,
  Date STRING,
  CustomerID INT64,
  ProdNumber STRING,
  Quantity INT64
);

CREATE OR REPLACE TABLE `PROJECT_ID.bank_muamalat.product_category` (
  CategoryID INT64,
  CategoryName STRING,
  CategoryAbbreviation STRING
);

-- The schema relationships are documented in docs/data_dictionary.md.
-- BigQuery PK/FK constraints, when declared NOT ENFORCED, are not validations.
-- The next script uses executable ASSERT statements instead.
