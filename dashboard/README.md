# Looker Studio dashboard — documentation

The original internship involved building a Looker Studio sales dashboard. A **verified, publicly accessible report URL and genuine dashboard screenshot are not currently available** in this repository. No invented link or recreated image is presented as the original dashboard.

## Suggested report pages

| Page | Metrics / visuals | Filters | Business question |
|---|---|---|---|
| Executive overview | Sales value, orders, units, AOV; monthly sales trend; YoY comparison | Date | Did overall sales improve? |
| Product mix | Category sales value and sales share, units and unit share, top products | Date, category | Which products create value vs. volume? |
| Geography and customers | Sales by city + state, unique purchasing customers, order-frequency bands | Date, state, city | Which segments are worth deeper analysis? |

## Report source

Use the BigQuery table built by [`sql/03_build_master_table.sql`](../sql/03_build_master_table.sql), or the minimized [`data/processed/master_table.csv`](../data/processed/master_table.csv) after running the migration script. The new table uses `customer_id`, not email. Explicitly configure `order_date` as a **Date** field. Prefer city/state jointly to avoid conflating same-named cities.

## Metric calculations

- **Sales value:** `SUM(total_sales)`; currency unverified.
- **Orders:** `COUNT_DISTINCT(order_id)`.
- **Units:** `SUM(order_qty)`.
- **Average order value:** total sales value / orders.
- **Purchasing customers:** `COUNT_DISTINCT(customer_id)`.
- **YoY:** calculated from 2020/2021 aggregates, not a hard-coded display string.

## Publication checklist

- [ ] Confirmed that the original dashboard or a rebuilt version is accessible to viewers.
- [ ] Added a screenshot from the **actual report**, not a fabricated dashboard image.
- [ ] Validated totals against [`docs/kpi_definitions.md`](../docs/kpi_definitions.md).
- [ ] Verified date parsing and all interactive filters.
- [ ] Removed email, names, addresses and personal fields from the published data source.
- [ ] Inserted verified dashboard URL in the repository README.

The two charts in `reports/figures/` are **documentation charts generated from validated CSV aggregates**, *not* screenshots of Looker Studio.
