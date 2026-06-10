
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select ethnicity_grouped
from `project-c29d8542-a733-449a-996`.`capstone_final_dataset_staging`.`stg_admissions`
where ethnicity_grouped is null



  
  
      
    ) dbt_internal_test