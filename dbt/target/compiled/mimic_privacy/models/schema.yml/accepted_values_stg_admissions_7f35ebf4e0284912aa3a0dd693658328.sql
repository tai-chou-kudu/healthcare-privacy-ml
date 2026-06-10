
    
    

with all_values as (

    select
        hospital_expire_flag as value_field,
        count(*) as n_records

    from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_staging`.`stg_admissions`
    group by hospital_expire_flag

)

select *
from all_values
where value_field not in (
    0,1
)


