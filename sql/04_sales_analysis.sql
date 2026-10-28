-- STEP 4: Reproduce the portfolio KPIs using the anonymized master table.
-- Run one statement at a time if preferred. Replace PROJECT_ID throughout.

-- 1) KPI overview / the 3,339 orders are at order grain.
SELECT
  COUNT(*) AS total_orders,
  COUNT(DISTINCT customer_id) AS purchasing_customers,
  SUM(order_qty) AS units_sold,
  ROUND(SUM(total_sales), 2) AS sales_value,
  ROUND(SAFE_DIVIDE(SUM(total_sales), COUNT(*)), 2) AS average_order_value
FROM `PROJECT_ID.bank_muamalat.master_table`;

-- 2) Annual trend and year-over-year comparison.
WITH annual AS (
  SELECT EXTRACT(YEAR FROM order_date) AS sales_year,
         ROUND(SUM(total_sales), 2) AS sales_value,
         COUNT(*) AS orders
  FROM `PROJECT_ID.bank_muamalat.master_table`
  GROUP BY 1
)
SELECT *,
  ROUND(100 * SAFE_DIVIDE(
    sales_value - LAG(sales_value) OVER (ORDER BY sales_year),
    LAG(sales_value) OVER (ORDER BY sales_year)
  ), 2) AS yoy_sales_change_pct
FROM annual ORDER BY sales_year;

-- 3) Monthly trend.
SELECT
  DATE_TRUNC(order_date, MONTH) AS sales_month,
  ROUND(SUM(total_sales), 2) AS sales_value,
  SUM(order_qty) AS units_sold,
  COUNT(*) AS orders
FROM `PROJECT_ID.bank_muamalat.master_table`
GROUP BY 1 ORDER BY 1;

-- 4) Product category: compare sales-value share with unit share.
WITH grouped AS (
  SELECT category_name,
         ROUND(SUM(total_sales), 2) AS sales_value,
         SUM(order_qty) AS units_sold,
         COUNT(*) AS orders
  FROM `PROJECT_ID.bank_muamalat.master_table`
  GROUP BY category_name
)
SELECT *,
  ROUND(100 * SAFE_DIVIDE(sales_value, SUM(sales_value) OVER ()), 2)
    AS sales_share_pct,
  ROUND(100 * SAFE_DIVIDE(units_sold, SUM(units_sold) OVER ()), 2)
    AS unit_share_pct
FROM grouped ORDER BY sales_value DESC;

-- 5) Top cities by sales; city names can be ambiguous across US states.
SELECT
  cust_city, cust_state,
  ROUND(SUM(total_sales), 2) AS sales_value,
  SUM(order_qty) AS units_sold,
  COUNT(*) AS orders
FROM `PROJECT_ID.bank_muamalat.master_table`
GROUP BY 1, 2 ORDER BY sales_value DESC LIMIT 10;

-- 6) Multi-order purchasing customer share (not cohort retention rate).
WITH customer_orders AS (
  SELECT customer_id, COUNT(DISTINCT order_id) AS n_orders
  FROM `PROJECT_ID.bank_muamalat.master_table`
  GROUP BY customer_id
)
SELECT
  COUNT(*) AS purchasing_customers,
  COUNTIF(n_orders >= 2) AS multi_order_customers,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(n_orders >= 2), COUNT(*)), 2)
    AS multi_order_customer_share_pct
FROM customer_orders;

-- 7) Locate categories contributing to the change in 2021.
WITH yearly_category AS (
  SELECT category_name, EXTRACT(YEAR FROM order_date) AS sales_year,
         SUM(total_sales) AS sales_value
  FROM `PROJECT_ID.bank_muamalat.master_table`
  WHERE EXTRACT(YEAR FROM order_date) IN (2020, 2021)
  GROUP BY 1, 2
)
SELECT category_name,
  ROUND(SUM(IF(sales_year = 2020, sales_value, 0)), 2) AS sales_2020,
  ROUND(SUM(IF(sales_year = 2021, sales_value, 0)), 2) AS sales_2021,
  ROUND(SUM(IF(sales_year = 2021, sales_value, 0))
      - SUM(IF(sales_year = 2020, sales_value, 0)), 2) AS absolute_change,
  ROUND(100 * SAFE_DIVIDE(
      SUM(IF(sales_year = 2021, sales_value, 0))
    - SUM(IF(sales_year = 2020, sales_value, 0)),
      SUM(IF(sales_year = 2020, sales_value, 0))), 2) AS yoy_pct
FROM yearly_category GROUP BY category_name ORDER BY absolute_change ASC;
