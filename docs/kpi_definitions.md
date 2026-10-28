# KPI definitions and interpretation

All metrics in this project describe **2020–2021 transactions**, not Bank Muamalat banking operations. The original dataset does **not label a monetary currency**. Calculations are based on listed unit price and quantity; discounts, returns, cost of goods, freight and tax are absent.

| KPI | Definition | Verified dataset result | Caveat |
|---|---|---:|---|
| Sales value | `SUM(Quantity * Price)` | 1,754,750.57 | Currency unspecified; not net revenue/profit |
| Orders | `COUNT(DISTINCT OrderID)` | 3,339 | Order is one record in this source |
| Units sold | `SUM(Quantity)` | 11,654 | Not number of products/styles |
| Purchasing customers | `COUNT(DISTINCT CustomerID)` in Orders | 1,671 | Different from 2,123 dimension records |
| Average order value | Sales value / orders | 525.53 | Currency unspecified |
| 2020 sales | `SUM(total_sales)` where `YEAR(date)=2020` | 913,210.09 | Full data calendar year |
| 2021 sales | `SUM(total_sales)` where `YEAR(date)=2021` | 841,540.48 | Full data calendar year |
| YoY sales change | `(sales_2021 / sales_2020 - 1) * 100` | −7.85% | Cannot establish why sales changed |
| Category sales share | `category_sales / all_sales * 100` | Robots 42.37% | Not the same as gross margin share |
| Category unit share | `category_qty / all_units * 100` | eBooks 26.80% | Different unit prices explain mixed shares |
| Multi-order customer share | `count(customers with ≥2 orders) / purchasing_customers` | 59.07% | **Not** cohort retention rate |

## Business interpretation rules

- Use **sales value** for `Quantity × Price`, unless the source identifies the monetary currency and accounting definition.
- Do not call the total **profit**, as neither costs nor margins are supplied.
- Do not call `multi-order customer share` **retention** without a defined start cohort, observation interval, and return event.
- Comparisons by city should include **state** because the same city name may exist in multiple states.
- When evaluating marketing recommendations, measure incremental performance against an appropriate comparison group, and calculate profitability if cost data becomes available.
