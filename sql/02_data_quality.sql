-- STEP 2: Run ONLY AFTER uploading the four public CSV files to BigQuery.
-- This is an executable precondition check: if any assertion fails, fix data
-- before continuing to 03_build_master_table.sql.
-- Replace PROJECT_ID with your own Google Cloud project ID.

-- Non-null and unique candidate primary keys
ASSERT (
  SELECT COUNT(*) = COUNT(DISTINCT CustomerID)
     AND COUNTIF(CustomerID IS NULL) = 0
  FROM `PROJECT_ID.bank_muamalat.customers`
) AS 'customers: CustomerID must be unique and non-null';

ASSERT (
  SELECT COUNT(*) = COUNT(DISTINCT ProdNumber)
     AND COUNTIF(ProdNumber IS NULL) = 0
  FROM `PROJECT_ID.bank_muamalat.products`
) AS 'products: ProdNumber must be unique and non-null';

ASSERT (
  SELECT COUNT(*) = COUNT(DISTINCT OrderID)
     AND COUNTIF(OrderID IS NULL) = 0
  FROM `PROJECT_ID.bank_muamalat.orders`
) AS 'orders: OrderID must be unique and non-null';

ASSERT (
  SELECT COUNT(*) = COUNT(DISTINCT CategoryID)
     AND COUNTIF(CategoryID IS NULL) = 0
  FROM `PROJECT_ID.bank_muamalat.product_category`
) AS 'product_category: CategoryID must be unique and non-null';

-- Referential integrity (LEFT JOIN intentionally also catches NULL FK values)
ASSERT (
  SELECT COUNT(*) = 0
  FROM `PROJECT_ID.bank_muamalat.orders` o
  LEFT JOIN `PROJECT_ID.bank_muamalat.customers` c
    ON o.CustomerID = c.CustomerID
  WHERE c.CustomerID IS NULL
) AS 'orders: unknown customer keys';

ASSERT (
  SELECT COUNT(*) = 0
  FROM `PROJECT_ID.bank_muamalat.orders` o
  LEFT JOIN `PROJECT_ID.bank_muamalat.products` p
    ON o.ProdNumber = p.ProdNumber
  WHERE p.ProdNumber IS NULL
) AS 'orders: unknown product keys';

ASSERT (
  SELECT COUNT(*) = 0
  FROM `PROJECT_ID.bank_muamalat.products` p
  LEFT JOIN `PROJECT_ID.bank_muamalat.product_category` pc
    ON p.Category = pc.CategoryID
  WHERE pc.CategoryID IS NULL
) AS 'products: unknown category keys';

-- Valid dates and numerical values
ASSERT (
  SELECT COUNT(*) = 0
  FROM `PROJECT_ID.bank_muamalat.orders`
  WHERE SAFE.PARSE_DATE('%d/%m/%Y', Date) IS NULL
) AS 'orders: Date must use valid DD/MM/YYYY';

ASSERT (
  SELECT COUNT(*) = 0
  FROM `PROJECT_ID.bank_muamalat.orders`
  WHERE Quantity IS NULL OR Quantity <= 0
) AS 'orders: Quantity must be positive';

ASSERT (
  SELECT COUNT(*) = 0
  FROM `PROJECT_ID.bank_muamalat.products`
  WHERE Price IS NULL OR Price < 0
) AS 'products: Price must be nonnegative';

ASSERT (
  SELECT COUNT(*) = 0
  FROM `PROJECT_ID.bank_muamalat.customers`
  WHERE CustomerCity IS NULL OR TRIM(CustomerCity) = ''
) AS 'customers: CustomerCity must not be blank';

-- Row counts and date coverage: compare with baseline in README.
SELECT 'customers' AS table_name, COUNT(*) AS row_count
  FROM `PROJECT_ID.bank_muamalat.customers`
UNION ALL SELECT 'products', COUNT(*) FROM `PROJECT_ID.bank_muamalat.products`
UNION ALL SELECT 'orders', COUNT(*) FROM `PROJECT_ID.bank_muamalat.orders`
UNION ALL SELECT 'product_category', COUNT(*) FROM `PROJECT_ID.bank_muamalat.product_category`;

SELECT
  MIN(SAFE.PARSE_DATE('%d/%m/%Y', Date)) AS min_order_date,
  MAX(SAFE.PARSE_DATE('%d/%m/%Y', Date)) AS max_order_date,
  COUNT(*) AS orders
FROM `PROJECT_ID.bank_muamalat.orders`;
