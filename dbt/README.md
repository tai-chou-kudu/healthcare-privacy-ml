# dbt — MIMIC-III Privacy-Utility Tradeoff Pipeline

This dbt project sits on top of the BigQuery preprocessing pipeline for the
**Privacy-Utility Tradeoffs in Healthcare AI** MS Data Science capstone (CUNY SPS, DATA 698).

## Stack
- **dbt Core** + **dbt-bigquery**
- **Google BigQuery** (project: `project-c29d8542-a733-449a-996`)
- **Source data:** MIMIC-III clinical database, preprocessed into `capstone_final_dataset.final_table`

## Model Architecture

```
capstone_final_dataset.final_table   ← BigQuery source (existing preprocessing output)
        │
        ├── stg_admissions           (view)  — cleans admissions, derives LOS + privacy risk
        ├── stg_diagnoses            (view)  — extracts ICD-9 codes, maps disease categories
        │
        └── mart_cohort_privacy      (table) — final ML-ready cohort, joined + audited
```

## Setup

### 1. Install dependencies
```bash
pip install dbt-core dbt-bigquery
```

### 2. Authenticate with GCP
```bash
gcloud auth application-default login
```

### 3. Copy profiles.yml to your dbt home directory
```bash
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml
```

### 4. Run the pipeline
```bash
cd dbt/
dbt debug          # verify connection
dbt run            # build all models
dbt test           # run data quality tests
dbt docs generate  # generate documentation
dbt docs serve     # open docs in browser
```

## Data Quality Tests

Tests are defined in `models/schema.yml` and cover:
- `not_null` — key fields are never null
- `unique` — `hadm_id` is unique per admission in staging and mart
- `accepted_values` — `reidentification_risk` is always one of: `low_risk`, `medium_risk`, `high_risk`

## Resume Context

> "Extended MS capstone healthcare privacy ML pipeline with dbt on BigQuery,
> implementing staged data models, automated data quality tests, and documentation
> to create a governed, auditable cohort for downstream ML modeling."
