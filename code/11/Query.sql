select 
  e.employee_id,
  e.first_name || ' ' || e.last_name employee,
  e.email,
  e.hire_date,
  e.job_id,
  e.salary,
  e.commission_pct,
  d.department_name department
from
  HR.employees e
join 
  HR.departments d
  on e.department_id = d.department_id
where
  e.commission_pct  > :commission_threshold