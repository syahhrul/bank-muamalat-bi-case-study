-- ============================================================================
-- Bank Muamalat x Rakamin Academy — BI Analyst Virtual Internship Final Task
-- Case Study: Analisis Penjualan PT Sejahtera Bersama
-- Google BigQuery Standard SQL
--
-- Ganti `PROJECT_ID.DATASET_ID` di seluruh file ini dengan project & dataset
-- BigQuery kamu sendiri, misalnya: `bank-muamalat-493716.bank_muamalat`
-- ============================================================================


-- ============================================================================
-- 0. SETUP DATASET
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS `PROJECT_ID.bank_muamalat`
OPTIONS (
  location = 'US'
);


-- ============================================================================
-- 1. CREATE TABLE — struktur 4 tabel sumber
--    (Gunakan ini jika perlu membuat ulang tabel setelah data di sandbox hilang.
--     Setelah tabel dibuat, load data dari file CSV lewat BigQuery Console:
--     "Create Table" > Source: Upload > File: Customers.csv / Orders.csv /
--     Products.csv / ProductCategory.csv > Schema: Auto detect)
-- ============================================================================

CREATE TABLE IF NOT EXISTS `PROJECT_ID.bank_muamalat.customers` (
  CustomerID      INT64,
  FirstName       STRING,
  LastName        STRING,
  CustomerEmail   STRING,
  CustomerPhone   STRING,
  CustomerAddress STRING,
  CustomerCity    STRING,
  CustomerState   STRING,
  CustomerZip     STRING
);

CREATE TABLE IF NOT EXISTS `PROJECT_ID.bank_muamalat.products` (
  ProdNumber STRING,
  ProdName   STRING,
  Category   INT64,
  Price      NUMERIC
);

CREATE TABLE IF NOT EXISTS `PROJECT_ID.bank_muamalat.orders` (
  OrderID    INT64,
  Date       DATE,
  CustomerID INT64,
  ProdNumber STRING,
  Quantity   INT64
);

CREATE TABLE IF NOT EXISTS `PROJECT_ID.bank_muamalat.product_category` (
  CategoryID           INT64,
  CategoryName         STRING,
  CategoryAbbreviation STRING
);


-- ============================================================================
-- 2. SOAL 1 — PRIMARY KEY pada 4 tabel
--    customers        -> CustomerID
--    products         -> ProdNumber
--    orders           -> OrderID
--    product_category -> CategoryID
--    (BigQuery tidak menegakkan PK/FK secara fisik, sehingga constraint
--     dideklarasikan sebagai NOT ENFORCED — fungsinya sebagai dokumentasi
--     skema dan dipakai oleh BI tools/optimizer, bukan validasi data.)
-- ============================================================================

ALTER TABLE `PROJECT_ID.bank_muamalat.customers`
  ADD PRIMARY KEY (CustomerID) NOT ENFORCED;

ALTER TABLE `PROJECT_ID.bank_muamalat.orders`
  ADD PRIMARY KEY (OrderID) NOT ENFORCED;

ALTER TABLE `PROJECT_ID.bank_muamalat.product_category`
  ADD PRIMARY KEY (CategoryID) NOT ENFORCED;

ALTER TABLE `PROJECT_ID.bank_muamalat.products`
  ADD PRIMARY KEY (ProdNumber) NOT ENFORCED;


-- ============================================================================
-- 3. SOAL 2 — RELATIONSHIP / FOREIGN KEY antar 4 tabel
--    product_category (1) --- (N) products   : products.Category      -> product_category.CategoryID
--    products          (1) --- (N) orders     : orders.ProdNumber      -> products.ProdNumber
--    customers         (1) --- (N) orders     : orders.CustomerID      -> customers.CustomerID
--    `orders` adalah fact table; customers & products (dengan product_category)
--    adalah dimension table di sekelilingnya.
-- ============================================================================

ALTER TABLE `PROJECT_ID.bank_muamalat.products`
  ADD CONSTRAINT fk_category FOREIGN KEY (Category)
  REFERENCES `PROJECT_ID.bank_muamalat.product_category` (CategoryID) NOT ENFORCED;

ALTER TABLE `PROJECT_ID.bank_muamalat.orders`
  ADD CONSTRAINT fk_customer FOREIGN KEY (CustomerID)
  REFERENCES `PROJECT_ID.bank_muamalat.customers` (CustomerID) NOT ENFORCED;

ALTER TABLE `PROJECT_ID.bank_muamalat.orders`
  ADD CONSTRAINT fk_prod FOREIGN KEY (ProdNumber)
  REFERENCES `PROJECT_ID.bank_muamalat.products` (ProdNumber) NOT ENFORCED;


-- ============================================================================
-- 4. SOAL 3 — MASTER TABLE (LEFT JOIN 4 tabel)
--    Kolom: cust_email, cust_city, order_date, order_qty, product_name,
--           product_price, category_name, total_sales
--    Diurutkan ASC berdasarkan tanggal transaksi.
--    Catatan: CustomerEmail dibersihkan dengan SPLIT(...)[OFFSET(0)] karena
--    data sumber menyisipkan artefak "#mailto:...#" di belakang tiap email.
-- ============================================================================

CREATE OR REPLACE TABLE `PROJECT_ID.bank_muamalat.master_table` AS
SELECT
  SPLIT(c.CustomerEmail, '#')[OFFSET(0)] AS cust_email,
  c.CustomerCity                          AS cust_city,
  o.Date                                   AS order_date,
  o.Quantity                               AS order_qty,
  p.ProdName                               AS product_name,
  p.Price                                  AS product_price,
  pc.CategoryName                          AS category_name,
  (o.Quantity * p.Price)                   AS total_sales
FROM `PROJECT_ID.bank_muamalat.orders` AS o
LEFT JOIN `PROJECT_ID.bank_muamalat.customers`        AS c  ON o.CustomerID = c.CustomerID
LEFT JOIN `PROJECT_ID.bank_muamalat.products`         AS p  ON o.ProdNumber = p.ProdNumber
LEFT JOIN `PROJECT_ID.bank_muamalat.product_category` AS pc ON p.Category   = pc.CategoryID
ORDER BY o.Date ASC;

-- Export hasilnya ke CSV: BigQuery Console > tabel master_table > Export > Export to GCS,
-- atau jalankan SELECT * FROM master_table lalu klik "Save Results > CSV (local file)".


-- ============================================================================
-- 5. PERMANENT FIX — supaya tabel/data TIDAK hilang lagi
--    Root cause: BigQuery Sandbox (tanpa billing account) memberi *default
--    table expiration 60 hari* pada SETIAP tabel/partition, apa pun aktivitasnya.
--    Setelah 60 hari, tabel otomatis terhapus — ini bukan bug, tapi memang
--    perilaku default Sandbox.
--
--    Jalankan query di bawah SETELAH project di-upgrade dari Sandbox
--    (link billing account, tetap bisa $0 karena masih dalam free tier
--    10GB storage / 1TB query per bulan):
-- ============================================================================

-- Hilangkan default expiration di level dataset:
ALTER SCHEMA `PROJECT_ID.bank_muamalat`
  SET OPTIONS (default_table_expiration_days = NULL);

-- Hilangkan expiration di masing-masing tabel yang sudah ada:
ALTER TABLE `PROJECT_ID.bank_muamalat.customers`        SET OPTIONS (expiration_timestamp = NULL);
ALTER TABLE `PROJECT_ID.bank_muamalat.products`         SET OPTIONS (expiration_timestamp = NULL);
ALTER TABLE `PROJECT_ID.bank_muamalat.orders`            SET OPTIONS (expiration_timestamp = NULL);
ALTER TABLE `PROJECT_ID.bank_muamalat.product_category` SET OPTIONS (expiration_timestamp = NULL);
ALTER TABLE `PROJECT_ID.bank_muamalat.master_table`      SET OPTIONS (expiration_timestamp = NULL);

-- Jika TIDAK ingin upgrade billing sama sekali, jangan andalkan BigQuery
-- Sandbox sebagai data source permanen untuk Looker Studio. Lihat
-- SOLUTION.md untuk alternatif yang 100% gratis dan tidak pernah expired.
