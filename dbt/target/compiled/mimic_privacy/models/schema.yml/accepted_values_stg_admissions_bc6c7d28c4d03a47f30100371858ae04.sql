
    
    

with all_values as (

    select
        ethnicity_grouped as value_field,
        count(*) as n_records

    from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_staging`.`stg_admissions`
    group by ethnicity_grouped

)

select *
from all_values
where value_field not in (
    'White','Black/African American','Hispanic/Latino','Asian','Other','Unknown'
)


