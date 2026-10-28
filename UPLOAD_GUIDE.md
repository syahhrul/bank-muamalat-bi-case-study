# Upload guide — replace the old repository content safely

This is a **revision package**, not a fresh copy of the internship raw datasets. It is meant to be unpacked **on top of a local clone** of the existing GitHub repository. Do **not** upload the ZIP as one file to GitHub expecting it to expand automatically.

## 1. One-time migration (Windows PowerShell)

Run in a folder where you have write permissions:

```powershell
git clone https://github.com/syahhrul/bank-muamalat-bi-case-study.git
cd bank-muamalat-bi-case-study
```

Copy `bank-muamalat-polished-UPDATE.zip` into that folder, then extract it **into this same folder** (overwrite `README.md` if prompted). PowerShell example:

```powershell
Expand-Archive -Path .\bank-muamalat-polished-UPDATE.zip -DestinationPath . -Force
```

Run the one-time migration and verification with Python 3.10+:

```powershell
python scripts/prepare_public_data.py
python scripts/verify_public_data.py --write-report
```

The first script:
- generates `data/raw/Customers.csv` with only ID, city and state (no names/emails/phones/addresses),
- moves the other three source CSVs into `data/raw/`,
- rebuilds `data/processed/master_table.csv` without email from the original sources,
- backs up the original customer and master CSV files to `.local_backup/` (ignored by Git),
- moves the old SQL into `reports/internship_original_queries.sql` as a **historical artifact only**,
- moves/renames the original presentation into `reports/bank_muamalat_vix_presentation.pptx`.

It does not overwrite your Git history or push anything to GitHub.

## 2. Review before committing

```powershell
git status --short
git diff --stat
```

Expected changes include: new docs, SQL, scripts, figures and workflow; deleted old root CSVs and original SQL/PPT; equivalent safe replacements under `data/` and `reports/`.

**Open `data/raw/Customers.csv` and `data/processed/master_table.csv` to confirm no direct personal identifiers are present.** The verifier checks the public schemas and figures but cannot certify legal redistribution rights.

If the source dataset or Git history contains real personal data without permission, assess whether rewriting history or recreating a clean repository is necessary **before publishing**. Deleting current files does not erase earlier commits. Rewriting a shared repo's history can invalidate collaborators' clones; proceed carefully. You can also publish just the SQL/docs while obtaining permission for the data.

## 3. Commit and push

After checking the new files and data rights:

```powershell
git add -A
git commit -m "Polish BI case study with validated insights and privacy-safe data"
git push origin main
```

GitHub Actions runs `scripts/verify_public_data.py` on each push. Check the **Actions** tab to see the result. The verification baseline assumes the **original 2020–2021 case-study dataset**, so it is expected to fail if you substitute a different dataset.

## 4. Final manual tasks

- Confirm the original educational dataset is permitted to be redistributed publicly.
- Verify the intended currency; the files themselves do not state IDR, USD or another currency.
- Add an authentic screenshot from Looker Studio and a public dashboard link **only after testing access**. Update `dashboard/README.md` and `README.md`.
- Review the original PPT for private details, wording, and any monetary-label errors before republishing.
- If updating the presentation itself, keep separate historic and revised versions so internship-era results are not misrepresented.

**You do not need to install any third-party Python packages to run the data migration and validation.**
