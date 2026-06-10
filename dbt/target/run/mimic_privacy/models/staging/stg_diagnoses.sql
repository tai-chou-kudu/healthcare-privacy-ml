

  create or replace view `project-c29d8542-a733-449a-996`.`capstone_final_dataset_staging`.`stg_diagnoses`
  OPTIONS()
  as -- stg_diagnoses.sql
-- Stage 2: Extract diagnosis codes from the preprocessed final table.
-- Pivots and cleans ICD-9 diagnostic coding for downstream ML feature engineering.
-- Primary diagnoses are flagged for use as prediction targets.

with source as (

    select * from `project-c29d8542-a733-449a-996`.`capstone_final_dataset`.`final_table`

),

diagnoses as (

    select
        subject_id,
        hadm_id,

        -- ICD code fields (adjust column names to match your final_table schema)
        icd9_code,
        seq_num,

        -- Flag primary diagnosis (seq_num = 1 is the principal diagnosis in MIMIC-III)
        case
            when seq_num = 1 then true
            else false
        end as is_primary_diagnosis,

        -- Broad disease category derived from ICD-9 code prefix
        case
            when icd9_code like 'E%' or icd9_code like 'V%'
                then 'External/Supplementary'
            when cast(left(icd9_code, 3) as int64) between 1   and 139
                then 'Infectious Disease'
            when cast(left(icd9_code, 3) as int64) between 140 and 239
                then 'Neoplasms'
            when cast(left(icd9_code, 3) as int64) between 240 and 279
                then 'Endocrine/Metabolic'
            when cast(left(icd9_code, 3) as int64) between 280 and 289
                then 'Blood Disorders'
            when cast(left(icd9_code, 3) as int64) between 290 and 319
                then 'Mental Disorders'
            when cast(left(icd9_code, 3) as int64) between 390 and 459
                then 'Circulatory'
            when cast(left(icd9_code, 3) as int64) between 460 and 519
                then 'Respiratory'
            when cast(left(icd9_code, 3) as int64) between 520 and 579
                then 'Digestive'
            when cast(left(icd9_code, 3) as int64) between 800 and 999
                then 'Injury/Poisoning'
            else 'Other'
        end as disease_category

    from source

    where icd9_code is not null

),

deduplicated as (

    -- One row per patient-admission-code combination
    select distinct
        subject_id,
        hadm_id,
        icd9_code,
        seq_num,
        is_primary_diagnosis,
        disease_category

    from diagnoses

)

select * from deduplicated;

