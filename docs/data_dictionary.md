# Data dictionary and source provenance

**Dataset source:** educational retail-sales files supplied for the Bank Muamalat × Rakamin Academy BI VIX case study (PT Sejahtera Bersama). **Not banking account or transaction data.** Dataset license, exact currency, synthetic/anonymized status and public redistribution permissions **have not been independently verified**.

## Public data model

### `data/raw/Customers.csv` — 2,123 records

| Field | Type | Meaning |
|---|---|---|
| `CustomerID` | integer | Non-direct identifier used to join orders. Source identifier, not a newly salted hash. |
| `CustomerCity` | text | Customer city |
| `CustomerState` | text | Customer state / region |

The public file intentionally excludes the original first/last name, email, phone, street address and ZIP. Although these fields are excluded, **re-identification risk depends on the original dataset**; confirm permission to publish even reduced columns.

### `data/raw/Orders.csv` — 3,339 records

| Field | Type | Meaning |
|---|---|---|
| `OrderID` | integer | Unique order record key |
| `Date` | text (raw) | Order date in **DD/MM/YYYY** format; parse with `%d/%m/%Y` |
| `CustomerID` | integer | Foreign key referencing Customers |
| `ProdNumber` | text | Foreign key referencing Products |
| `Quantity` | integer | Positive units in record |

### `data/raw/Products.csv` — 70 records

| Field | Type | Meaning |
|---|---|---|
| `ProdNumber` | text | Unique product ID |
| `ProdName` | text | Product name |
| `Category` | integer | FK to ProductCategory.CategoryID |
| `Price` | decimal | Unit list price; source currency **not specified** |

### `data/raw/ProductCategory.csv` — 7 records

| Field | Type | Meaning |
|---|---|---|
| `CategoryID` | integer | Category key |
| `CategoryName` | text | Name of category |
| `CategoryAbbreviation` | text | Abbreviated category label |

## `data/processed/master_table.csv` — 3,339 records

| Field | Type | Meaning |
|---|---|---|
| `order_id` | integer | Original order ID; grain is one order record |
| `customer_id` | integer | Non-direct customer ID, not email |
| `cust_city` | text | City from Customers |
| `cust_state` | text | State from Customers |
| `order_date` | ISO date | Normalized transaction date (`YYYY-MM-DD`) |
| `order_qty` | integer | Quantity ordered |
| `product_id` | text | Product reference |
| `product_name` | text | Joined product name |
| `product_price` | decimal | List price per unit |
| `category_name` | text | Joined product category |
| `total_sales` | decimal | `order_qty * product_price`, rounded to 2 decimals |

## Key relationships and validation

- `Orders.CustomerID` → `Customers.CustomerID` (many-to-one).
- `Orders.ProdNumber` → `Products.ProdNumber` (many-to-one).
- `Products.Category` → `ProductCategory.CategoryID` (many-to-one).
- Historical CSV review found unique primary keys, zero missing foreign-key references and full dates from **2020-01-01 through 2021-12-31**.
- The [SQL assertions](../sql/02_data_quality.sql) and [local CSV verifier](../scripts/verify_public_data.py) reproduce these claims.
- BigQuery PK/FK constraints annotated `NOT ENFORCED` **are documentation, not data validation**.

## Privacy and license notes

1. **Do not publish** original `Customers.csv` fields containing names/contact/street addresses or the original `master_table.csv` containing email.
2. The migration script stores both original files in the locally ignored `.local_backup/`, **not** in the public upload.
3. Removing files from a commit does **not erase them from older Git history**. Review the original repository history and purge it if necessary using an appropriate tool and after coordinating with any collaborators.
4. If public redistribution rights are uncertain, do not push the data files until authorization is confirmed. The docs and SQL can be published independently.
5. Avoid service-account JSON keys, live client data or credentials in your Git repository.
