

  create or replace view `project-c29d8542-a733-449a-996`.`capstone_final_dataset_staging`.`stg_lab_features`
  OPTIONS()
  as -- stg_lab_features.sql
-- Stage 2: Validate the 3 continuous lab features used in ML experiments.
-- creatinine, bun, bicarbonate — exactly matching the notebook feature set:
--   features = ['age_at_admission', 'ethnicity_grouped_enc', 'gender', 'admission_type',
--               'creatinine', 'bun', 'bicarbonate']
--
-- Note: wbc, sodium, lactate exist in final_table but are not used in any
-- experiment (baseline, k-anonymity, DP, or membership inference attack).
-- They are passed through here for completeness but excluded from has_complete_labs.

with source as (

    select * from `project-c29d8542-a733-449a-996`.`capstone_final_dataset`.`final_table`

),

labs as (

    select
        subject_id,
        hadm_id,

        -- 3 lab features used in all notebook experiments
        creatinine,
        bun,
        bicarbonate,

        -- Additional lab columns present in final_table (not used in experiments)
        wbc,
        sodium,
        lactate,

        -- Completeness flag: based on the 3 features actually used in models
        case
            when creatinine  is not null
             and bun         is not null
             and bicarbonate is not null
            then true
            else false
        end as has_complete_labs,

        -- Outlier flags for the 3 active features
        case when creatinine > 20  then true else false end as creatinine_outlier,
        case when bun > 150        then true else false end as bun_outlier,
        case when bicarbonate < 5
          or bicarbonate > 45      then true else false end as bicarbonate_outlier

    from source

    where
        subject_id is not null
        and hadm_id is not null

)

select * from labs;

