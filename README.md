# Bank Muamalat x Rakamin Academy — BI Analyst Virtual Internship

Final task of the **Business Intelligence Virtual Internship Experience (VIX)** with **Bank Muamalat** (Rakamin Academy). Case study: *Analisis Penjualan PT Sejahtera Bersama* — a sales analytics project covering data modeling, SQL, and dashboarding in Google BigQuery + Looker Studio.

## 📌 Case Study Overview

As a BI Analyst for PT Sejahtera Bersama, the task was to:
1. Identify the primary key of 4 sales datasets (Customers, Products, Orders, ProductCategory).
2. Map the relationships between the 4 tables.
3. Build a master transaction table by joining all 4 tables.
4. Visualize the result as an interactive dashboard in Looker Studio.
5. Propose business recommendations to maintain/increase sales.

## 🗂️ Data Model

```
product_category (1) ───< (N) products (1) ───< (N) orders (N) >─── (1) customers
     CategoryID              Category                ProdNumber        CustomerID
                              ProdNumber              CustomerID
```

| Table | Primary Key | Rows |
|---|---|---|
| `customers` | `CustomerID` | 2,123 |
| `products` | `ProdNumber` | 70 |
| `orders` | `OrderID` | 3,339 |
| `product_category` | `CategoryID` | 7 |

`orders` is the fact table; `customers`, `products`, and `product_category` are dimension tables.

## ⚙️ Workflow

1. **Data Understanding & Primary Keys** — inspected all 4 raw tables in BigQuery, confirmed uniqueness of each PK candidate.
2. **Relationship Mapping** — validated referential integrity (no orphan foreign keys) and documented the ERD.
3. **Master Table (SQL)** — `LEFT JOIN` across all 4 tables in BigQuery to produce a single denormalized transaction table (`cust_email`, `cust_city`, `order_date`, `order_qty`, `product_name`, `product_price`, `category_name`, `total_sales`), sorted by transaction date. Also cleaned a data quality issue in `CustomerEmail` (a `#mailto:...#` artifact appended to every address in the source data).
4. **Dashboard (Looker Studio)** — interactive sales dashboard with Total Sales, Total Qty, Top Category/City breakdowns, Top-5 rankings, and Date/Category/City filters.
5. **Business Recommendations** — data-backed strategy for retention, upselling, and expansion.

## 📊 Key Findings

- **Total Sales:** ≈ Rp 1.75 billion · **Total Qty:** 11,654 units (Jan 2020 – Dec 2021)
- **Robots** is the top category by revenue (42.4% of total sales) despite lower unit volume.
- **eBooks** has the highest unit volume (3,123 units) but only 3.4% of revenue — high-volume, low-value.
- **Washington** and **Houston** are the top two cities by sales.

## 💡 Business Recommendations

1. Bundle high-value, low-volume products (Robots/Drones) with high-volume, low-value products (eBooks/Training Videos) to boost average order value.
2. Run loyalty programs and targeted promotions in top-performing cities (Washington, Houston).
3. Expand into cities with lower quantity but growth potential via localized digital marketing.
4. Prioritize stock and after-sales service for premium Robot variants — the largest revenue driver.
5. Explore a subscription/membership model for eBooks and Training Videos to better monetize their high transaction volume.
6. Investigate seasonal/competitive factors behind late-2021 sales trends and prepare corrective year-end promotions.

## 📁 Repository Structure

```
.
├── Customers.csv                 # Raw customer dimension data
├── Orders.csv                    # Raw order fact data
├── Products.csv                  # Raw product dimension data
├── ProductCategory.csv           # Raw product category dimension data
├── master_table.csv              # Final joined & cleaned table (dashboard source)
├── bank_muamalat_queries.sql     # Full BigQuery SQL: DDL, PK/FK, master table join
├── CaseStudy_BankMuamalat_Final.pptx  # Presentation deck
├── SOLUTION.md                   # Full written answers (Soal 1–5) + data-permanence fix
└── README.md
```

## 🧰 Tech Stack

`Google BigQuery` · `SQL` · `Looker Studio` · `Google Sheets`

## ▶️ How to Reproduce

1. Load `Customers.csv`, `Orders.csv`, `Products.csv`, `ProductCategory.csv` into BigQuery (see `CREATE TABLE` statements in `bank_muamalat_queries.sql`).
2. Run the `LEFT JOIN` query in `bank_muamalat_queries.sql` to regenerate `master_table.csv`.
3. Connect Looker Studio to the resulting table (or upload `master_table.csv` directly via Google Sheets / File Upload — see `SOLUTION.md` for why this is the more durable option on a free BigQuery Sandbox project).

> **Note:** BigQuery Sandbox auto-expires tables after 60 days. `SOLUTION.md` documents a permanent, free fix (Google Sheets as the Looker Studio data source) so the dashboard doesn't break again.

## 👤 Author

**Syahrul Mubarak**
Final-year Informatics student, Universitas Ahmad Dahlan Yogyakarta, focused on data analysis and business intelligence.
