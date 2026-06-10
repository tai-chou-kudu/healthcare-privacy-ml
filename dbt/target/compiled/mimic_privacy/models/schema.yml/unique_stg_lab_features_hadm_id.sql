
    
    

with dbt_test__target as (

  select hadm_id as unique_field
  from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_staging`.`stg_lab_features`
  where hadm_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


