
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select subject_id
from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_marts`.`mart_cohort_privacy`
where subject_id is null



  
  
      
    ) dbt_internal_test