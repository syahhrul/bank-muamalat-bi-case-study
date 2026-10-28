-- STEP 3: Run AFTER 02_data_quality.sql has passed.
-- Grain: one row per OrderID. No email/name/phone/street address in output.
-- Revenue-like metric is Quantity * list Price, before any unrecorded discounts,
-- returns, shipping fees or taxes; monetary currency is not specified in files.
-- Replace PROJECT_ID with your own Google Cloud project ID.

CREATE OR REPLACE TABLE `PROJECT_ID.bank_muamalat.master_table` AS
SELECT
  o.OrderID AS order_id,
  o.CustomerID AS customer_id,
  c.CustomerCity AS cust_city,
  c.CustomerState AS cust_state,
  SAFE.PARSE_DATE('%d/%m/%Y', o.Date) AS order_date,
  o.Quantity AS order_qty,
  o.ProdNumber AS product_id,
  p.ProdName AS product_name,
  p.Price AS product_price,
  pc.CategoryName AS category_name,
  ROUND(CAST(o.Quantity AS NUMERIC) * p.Price, 2) AS total_sales
FROM `PROJECT_ID.bank_muamalat.orders` AS o
LEFT JOIN `PROJECT_ID.bank_muamalat.customers` AS c
  ON o.CustomerID = c.CustomerID
LEFT JOIN `PROJECT_ID.bank_muamalat.products` AS p
  ON o.ProdNumber = p.ProdNumber
LEFT JOIN `PROJECT_ID.bank_muamalat.product_category` AS pc
  ON p.Category = pc.CategoryID;

-- Confirm no rows added/lost by the joins and that all rows have keys.
ASSERT (
  SELECT
    (SELECT COUNT(*) FROM `PROJECT_ID.bank_muamalat.master_table`) =
    (SELECT COUNT(*) FROM `PROJECT_ID.bank_muamalat.orders`)
) AS 'master table row count must match orders';

ASSERT (
  SELECT COUNT(*) = COUNT(DISTINCT order_id)
     AND COUNTIF(order_id IS NULL OR customer_id IS NULL
                 OR category_name IS NULL OR total_sales IS NULL) = 0
  FROM `PROJECT_ID.bank_muamalat.master_table`
) AS 'master table has invalid keys or missing joined fields';

-- Explicit ORDER BY belongs in the SELECT query used to export the table.
-- SELECT * FROM `PROJECT_ID.bank_muamalat.master_table` ORDER BY order_date, order_id;
