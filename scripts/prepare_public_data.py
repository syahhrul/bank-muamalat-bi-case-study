#!/usr/bin/env python3
"""Migrate the internship repository into a public-safe, reproducible layout.

Usage from the repository root:
    python scripts/prepare_public_data.py
    python scripts/verify_public_data.py

No third-party packages are needed. Make sure this repo was cloned with its
original four CSVs. The original customer/master CSVs are moved into a locally
ignored .local_backup/ folder; they must NOT be committed or re-uploaded.
"""

from __future__ import annotations

import csv
import shutil
from collections import Counter
from datetime import datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
PROCESSED = ROOT / "data" / "processed"
BACKUP = ROOT / ".local_backup"
REPORTS = ROOT / "reports"

SOURCE_FILES = ("Customers.csv", "Orders.csv", "Products.csv", "ProductCategory.csv")
CUSTOMER_PUBLIC_FIELDS = ("CustomerID", "CustomerCity", "CustomerState")
MASTER_FIELDS = (
    "order_id", "customer_id", "cust_city", "cust_state", "order_date",
    "order_qty", "product_id", "product_name", "product_price", "category_name",
    "total_sales",
)


def csv_read(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8-sig") as fh:
        rows = list(csv.DictReader(fh))
    if not rows:
        raise ValueError(f"No records found: {path}")
    return rows


def csv_write(path: Path, fields: tuple[str, ...], rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fields, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def assert_unique(rows: list[dict], col: str, table: str) -> None:
    keys = [row[col] for row in rows]
    if len(keys) != len(set(keys)) or any(not v for v in keys):
        raise ValueError(f"{table}.{col} must be non-blank and unique")


def load_sources() -> tuple[dict[str, list[dict]], dict[str, Path]]:
    result, locations = {}, {}
    for name in SOURCE_FILES:
        candidate = ROOT / name
        if not candidate.exists():
            candidate = RAW / name
        if not candidate.exists():
            raise FileNotFoundError(
                f"Missing {name}; clone original repository first, then copy the revision files into it."
            )
        result[name] = csv_read(candidate)
        locations[name] = candidate
    return result, locations


def main() -> None:
    sources, locations = load_sources()
    customers = sources["Customers.csv"]
    orders = sources["Orders.csv"]
    products = sources["Products.csv"]
    categories = sources["ProductCategory.csv"]

    for table, rows, field in (
        ("Customers", customers, "CustomerID"),
        ("Orders", orders, "OrderID"),
        ("Products", products, "ProdNumber"),
        ("ProductCategory", categories, "CategoryID"),
    ):
        assert_unique(rows, field, table)

    product_idx = {row["ProdNumber"]: row for row in products}
    customer_idx = {row["CustomerID"]: row for row in customers}
    category_idx = {row["CategoryID"]: row for row in categories}
    if any(row["CustomerID"] not in customer_idx or row["ProdNumber"] not in product_idx
           for row in orders):
        raise ValueError("Missing customer/product keys in Orders.csv")
    if any(row["Category"] not in category_idx for row in products):
        raise ValueError("Missing category keys in Products.csv")

    cleaned_customers = [
        {field: row[field].strip() for field in CUSTOMER_PUBLIC_FIELDS}
        for row in customers
    ]
    prepared = []
    for order in orders:
        product = product_idx[order["ProdNumber"]]
        customer = customer_idx[order["CustomerID"]]
        category = category_idx[product["Category"]]
        try:
            qty = int(order["Quantity"])
            price = Decimal(product["Price"])
            day = datetime.strptime(order["Date"], "%d/%m/%Y").date()
        except (InvalidOperation, ValueError) as exc:
            raise ValueError(f"Invalid order {order['OrderID']}: {exc}") from exc
        if qty <= 0 or price < 0:
            raise ValueError(f"Invalid qty/price in order {order['OrderID']}")
        prepared.append({
            "order_id": order["OrderID"],
            "customer_id": order["CustomerID"],
            "cust_city": customer["CustomerCity"],
            "cust_state": customer["CustomerState"],
            "order_date": day.isoformat(),
            "order_qty": qty,
            "product_id": order["ProdNumber"],
            "product_name": product["ProdName"],
            "product_price": f"{price:.2f}",
            "category_name": category["CategoryName"],
            "total_sales": f"{qty * price:.2f}",
        })
    prepared.sort(key=lambda r: (r["order_date"], int(r["order_id"])))

    # Data build succeeded: now write public files.
    RAW.mkdir(parents=True, exist_ok=True)
    PROCESSED.mkdir(parents=True, exist_ok=True)
    csv_write(RAW / "Customers.csv", CUSTOMER_PUBLIC_FIELDS, cleaned_customers)
    for name in SOURCE_FILES[1:]:
        path = RAW / name
        original = locations[name]
        if original != path:
            shutil.copy2(original, path)
    csv_write(PROCESSED / "master_table.csv", MASTER_FIELDS, prepared)

    # Make sensitive originals local-only; do not ever commit this directory.
    BACKUP.mkdir(parents=True, exist_ok=True)
    for name in ("Customers.csv", "master_table.csv"):
        old = ROOT / name
        if old.exists():
            target = BACKUP / name
            if not target.exists():
                shutil.move(str(old), str(target))
            else:
                old.unlink()  # already backed up in an earlier run

    # The other source CSVs are reproduced under data/raw.
    for name in SOURCE_FILES[1:]:
        old = ROOT / name
        if old.exists():
            old.unlink()

    REPORTS.mkdir(parents=True, exist_ok=True)
    legacy_sql = ROOT / "bank_muamalat_queries.sql"
    if legacy_sql.exists():
        shutil.move(str(legacy_sql), str(REPORTS / "internship_original_queries.sql"))
    for name in ("CaseStudy_BankMuamalat_Final (1).pptx", "CaseStudy_BankMuamalat_Final.pptx"):
        ppt = ROOT / name
        if ppt.exists():
            shutil.move(str(ppt), str(REPORTS / "bank_muamalat_vix_presentation.pptx"))
            break

    order_users = Counter(r["customer_id"] for r in prepared)
    print("Public data prepared safely:")
    print(f"  Customer reference rows: {len(cleaned_customers)} (no PII fields)")
    print(f"  Transactions: {len(prepared)}, purchasing customers: {len(order_users)}")
    print(f"  Sales total (currency unspecified): {sum(Decimal(r['total_sales']) for r in prepared):.2f}")
    print("  New files: data/raw/*.csv and data/processed/master_table.csv")
    print("  Old customer and master files: .local_backup/ (gitignored)")
    print("Run: python scripts/verify_public_data.py")
    print("IMPORTANT: past Git commits may still contain the old fields.")


if __name__ == "__main__":
    main()
