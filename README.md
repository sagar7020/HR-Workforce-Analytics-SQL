# HR-Workforce-Analytics-SQL
A SQL-based workforce analytics project built on a raw, messy HR dataset (22,214 employee records across 13 departments and 7 U.S. states). The project covers the full pipeline: staging a raw CSV, cleaning it entirely in SQL, and writing KPI queries for headcount, attrition, tenure, and diversity — the kind of analysis that feeds directly into an HR Power BI dashboard.
`Human_Resources.csv` — one row per employee: name, birthdate, gender,
race, department, job title, location, hire date, and termination date
(null if still active).

## Data quality issues found & fixed (in SQL, not pre-cleaned in Excel)

| Issue | Fix |
|---|---|
| ~1,000 `termdate` values fall in the future (up to 2041) — impossible for a termination date | Nulled out and reclassified as active employees |
| Two job titles contain typos that split what should be one title: `Data Coordiator`, `Relationshiop Manager` | Standardized via `CASE` mapping |
| Dates stored as text in inconsistent formats (`M/D/YYYY` vs `YYYY-MM-DD HH:MM:SS UTC`) | Cast with `STR_TO_DATE` into proper `DATE` columns |
| ~15,000 fully blank trailing rows in the source file | Excluded at load time |

## Project structure

```
01_schema.sql            -- staging table + typed production table
02_load_data.sql         -- LOAD DATA INFILE instructions (server-side and client-side options)
03_data_cleaning.sql     -- staging -> production transform, with cleaning logic documented inline
04_analysis_queries.sql  -- 13 KPI queries: headcount, attrition, tenure, diversity, generations
employees_raw.csv        -- source data, blank rows removed, ready to load
```

## How to run it

1. Create the schema: `mysql -u root -p < 01_schema.sql`
2. Load the raw CSV into staging: adjust the file path in `02_load_data.sql` to wherever
   MySQL can read it, then run it.
3. Clean and populate the production table: `mysql -u root -p < 03_data_cleaning.sql`
4. Run any query in `04_analysis_queries.sql` for the KPI you need.

## Sample results

**Overall headcount:** 22,214 employees — 19,333 active, 2,881 terminated (12.97% attrition)

**Attrition by department (highest first):**

| Department | Headcount | Attrition % |
|---|---|---|
| Auditing | 52 | 19.23% |
| Legal | 311 | 16.72% |
| Training | 1,692 | 13.59% |
| Support | 954 | 13.52% |
| Sales | 1,832 | 13.26% |
| Engineering | 6,686 | 13.13% |

**Workforce by generation:** Millennials (9,746) and Gen X (9,510) make up ~87% of
headcount; Gen Z (2,485) and Boomers (473) round out the rest.

## Why this project

Built to demonstrate the SQL side of an HR/workforce analytics workflow —
raw-to-clean data pipelines, KPI query design, and the kind of measures
(headcount, attrition rate, tenure, diversity mix) that map directly onto
Power BI dashboard cards and DAX measures.
