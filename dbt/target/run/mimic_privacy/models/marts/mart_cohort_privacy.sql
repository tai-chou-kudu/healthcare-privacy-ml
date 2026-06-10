
  
    

    create or replace table `project-c29d8542-a733-449a-996`.`capstone_final_dataset_marts`.`mart_cohort_privacy`
      
    
    

    
    OPTIONS()
    as (
      -- mart_cohort_privacy.sql
-- Final ML-ready cohort for Privacy-Utility Tradeoffs in Healthcare AI (DATA 698 Capstone).
-- Joins stg_admissions (demographics + k-anon fields) with stg_lab_features (3 lab values).
-- Produces the governed, auditable input for:
--   - Baseline logistic regression (5-fold stratified CV)
--   - K-anonymity experiments (age_band + ethnicity_grouped, k=5/10/25/50)
--   - Differential privacy experiments (epsilon=0.1/1/5/10, diffprivlib Laplace)
--   - Membership inference attack evaluation
--
-- Feature set mirrors notebook exactly:
--   ['age_at_admission', 'ethnicity_grouped_enc', 'gender', 'admission_type',
--    'creatinine', 'bun', 'bicarbonate']

with admissions as (

    select * from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_staging`.`stg_admissions`

),

labs as (

    select * from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_staging`.`stg_lab_features`

),

cohort as (

    select
        -- Keys
        a.subject_id,
        a.hadm_id,

        -- Demographic features (ML inputs)
        a.age_at_admission,
        a.gender,
        a.ethnicity,
        a.admission_type,

        -- K-anonymity generalized fields (derived in dbt, mirrors notebook logic)
        a.age_band,
        a.ethnicity_grouped,

        -- Privacy metadata
        a.reidentification_risk,

        -- Lab features — 3 used in all notebook experiments
        l.creatinine,
        l.bun,
        l.bicarbonate,
        l.has_complete_labs,

        -- Additional lab columns in final_table (not used in experiments)
        l.wbc,
        l.sodium,
        l.lactate,

        -- Outlier audit flags
        l.creatinine_outlier,
        l.bun_outlier,
        l.bicarbonate_outlier,

        -- Target variables
        a.hospital_expire_flag,   -- primary:   mortality (10.86% positive rate)
        a.readmitted_30,          -- secondary: 30-day readmission (6.25% positive rate)

        -- Data governance audit columns
        current_timestamp()   as dbt_loaded_at,
        'mart_cohort_privacy' as dbt_source_model

    from admissions a
    inner join labs l
        on  a.subject_id = l.subject_id
        and a.hadm_id    = l.hadm_id

)

select * from cohort
    );
  