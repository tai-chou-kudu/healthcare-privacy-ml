
    
    

with all_values as (

    select
        reidentification_risk as value_field,
        count(*) as n_records

    from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_marts`.`mart_cohort_privacy`
    group by reidentification_risk

)

select *
from all_values
where value_field not in (
    'low_risk','medium_risk','high_risk'
)


