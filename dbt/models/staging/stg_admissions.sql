-- stg_admissions.sql
-- Stage 1: Clean admission-level cohort and derive privacy fields.
-- Ethnicity grouping uses exact-match mapping from the notebook ethnicity_map dict
-- (41 raw MIMIC-III values → 6 categories). Age banding uses 10-year bins
-- matching notebook: generalize_age(x, bins=10) = (age // 10) * 10.

with source as (

    select * from {{ source('capstone', 'final_table') }}

),

cleaned as (

    select
        subject_id,
        hadm_id,

        -- Demographics
        age_at_admission,
        gender,
        ethnicity,
        admission_type,

        -- Age banding: matches notebook generalize_age(x, bins=10)
        -- Returns floor of 10-year band: 18→10, 27→20, 57→50, 78→70
        cast(floor(age_at_admission / 10) * 10 as int64) as age_band,

        -- Ethnicity grouping: exact match to notebook ethnicity_map
        -- 41 raw MIMIC-III values → 6 categories
        case ethnicity
            when 'WHITE'                                                    then 'White'
            when 'WHITE - RUSSIAN'                                          then 'White'
            when 'WHITE - OTHER EUROPEAN'                                   then 'White'
            when 'WHITE - BRAZILIAN'                                        then 'White'
            when 'WHITE - EASTERN EUROPEAN'                                 then 'White'
            when 'BLACK/AFRICAN AMERICAN'                                   then 'Black/African American'
            when 'BLACK/CAPE VERDEAN'                                       then 'Black/African American'
            when 'BLACK/HAITIAN'                                            then 'Black/African American'
            when 'BLACK/AFRICAN'                                            then 'Black/African American'
            when 'HISPANIC OR LATINO'                                       then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - PUERTO RICAN'                          then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - DOMINICAN'                             then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - GUATEMALAN'                            then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - CUBAN'                                 then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - SALVADORAN'                            then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - MEXICAN'                               then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - CENTRAL AMERICAN (OTHER)'              then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - COLOMBIAN'                             then 'Hispanic/Latino'
            when 'HISPANIC/LATINO - HONDURAN'                              then 'Hispanic/Latino'
            when 'ASIAN'                                                    then 'Asian'
            when 'ASIAN - CHINESE'                                         then 'Asian'
            when 'ASIAN - ASIAN INDIAN'                                    then 'Asian'
            when 'ASIAN - VIETNAMESE'                                      then 'Asian'
            when 'ASIAN - FILIPINO'                                        then 'Asian'
            when 'ASIAN - CAMBODIAN'                                       then 'Asian'
            when 'ASIAN - KOREAN'                                          then 'Asian'
            when 'ASIAN - OTHER'                                           then 'Asian'
            when 'ASIAN - JAPANESE'                                        then 'Asian'
            when 'ASIAN - THAI'                                            then 'Asian'
            when 'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER'               then 'Asian'
            when 'MIDDLE EASTERN'                                          then 'Other'
            when 'MULTI RACE ETHNICITY'                                    then 'Other'
            when 'AMERICAN INDIAN/ALASKA NATIVE'                           then 'Other'
            when 'AMERICAN INDIAN/ALASKA NATIVE FEDERALLY RECOGNIZED TRIBE' then 'Other'
            when 'CARIBBEAN ISLAND'                                        then 'Other'
            when 'SOUTH AMERICAN'                                          then 'Other'
            when 'PORTUGUESE'                                              then 'Other'
            when 'UNKNOWN/NOT SPECIFIED'                                   then 'Unknown'
            when 'UNABLE TO OBTAIN'                                        then 'Unknown'
            when 'PATIENT DECLINED TO ANSWER'                              then 'Unknown'
            else 'Other'   -- matches notebook .fillna('Other')
        end as ethnicity_grouped,

        -- Target variables
        hospital_expire_flag,
        readmitted_30,

        -- Re-identification risk proxy
        case
            when ethnicity in ('UNKNOWN/NOT SPECIFIED','UNABLE TO OBTAIN','PATIENT DECLINED TO ANSWER')
              or ethnicity is null                     then 'high_risk'
            when age_at_admission >= 80                then 'high_risk'
            when age_at_admission between 18 and 29   then 'medium_risk'
            else                                           'low_risk'
        end as reidentification_risk

    from source

    where
        age_at_admission between 18 and 89
        and subject_id           is not null
        and hadm_id              is not null
        and hospital_expire_flag is not null

)

select * from cleaned
