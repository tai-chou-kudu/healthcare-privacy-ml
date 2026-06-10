
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        readmitted_30 as value_field,
        count(*) as n_records

    from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_marts`.`mart_cohort_privacy`
    group by readmitted_30

)

select *
from all_values
where value_field not in (
    '0','1'
)



  
  
      
    ) dbt_internal_test