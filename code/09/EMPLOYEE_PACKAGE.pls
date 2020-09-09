CREATE OR REPLACE PACKAGE EMPLOYEE_PACKAGE AS 

  SUBTYPE t_employee_id IS HR.EMPLOYEES.EMPLOYEE_ID%TYPE;

  PROCEDURE insert_employee (
      o_employee_id OUT t_employee_id,
      i_first_name in HR.EMPLOYEES.FIRST_NAME%TYPE,
      i_last_name in HR.EMPLOYEES.LAST_NAME%TYPE,
      i_email in HR.EMPLOYEES.EMAIL%TYPE,
      i_job_id in HR.EMPLOYEES.JOB_ID%TYPE,
      i_hire_date in HR.EMPLOYEES.HIRE_DATE%TYPE,
      i_phone_number in HR.EMPLOYEES.PHONE_NUMBER%TYPE := NULL,      
      i_salary in HR.EMPLOYEES.SALARY%TYPE := NULL,
      i_commission_pct in HR.EMPLOYEES.COMMISSION_PCT%TYPE := NULL,
      i_manager_id in HR.EMPLOYEES.MANAGER_ID%TYPE := NULL,
      i_department_id in HR.EMPLOYEES.DEPARTMENT_ID%TYPE := NULL);

  PROCEDURE load_employee (
    i_employee_id IN t_employee_id,
    o_employees out sys_refcursor,
    o_locations out sys_refcursor);
    
  FUNCTION get_employee_manager(i_employee_id in t_employee_id) RETURN VARCHAR2;   

END EMPLOYEE_PACKAGE;
/


CREATE OR REPLACE PACKAGE BODY EMPLOYEE_PACKAGE AS

  PROCEDURE insert_employee (
      o_employee_id OUT t_employee_id,
      i_first_name in HR.EMPLOYEES.FIRST_NAME%TYPE,
      i_last_name in HR.EMPLOYEES.LAST_NAME%TYPE,
      i_email in HR.EMPLOYEES.EMAIL%TYPE,
      i_job_id in HR.EMPLOYEES.JOB_ID%TYPE,
      i_hire_date in HR.EMPLOYEES.HIRE_DATE%TYPE,
      i_phone_number in HR.EMPLOYEES.PHONE_NUMBER%TYPE := NULL,      
      i_salary in HR.EMPLOYEES.SALARY%TYPE := NULL,
      i_commission_pct in HR.EMPLOYEES.COMMISSION_PCT%TYPE := NULL,
      i_manager_id in HR.EMPLOYEES.MANAGER_ID%TYPE := NULL,
      i_department_id in HR.EMPLOYEES.DEPARTMENT_ID%TYPE := NULL) AS
  BEGIN
    insert into HR.EMPLOYEES
    (
      employee_id,
      first_name,
      last_name,
      email,
      phone_number,
      hire_date,
      job_id,
      salary,
      commission_pct,
      manager_id,
      department_id
    )
    values
    (
      HR.EMPLOYEES_SEQ.NEXTVAL,
      i_first_name,
      i_last_name,
      i_email,
      i_phone_number,
      i_hire_date,
      i_job_id,
      i_salary,
      i_commission_pct,
      i_manager_id,
      i_department_id
    ) RETURNING employee_id into o_employee_id;
    
  END insert_employee;

  PROCEDURE load_employee (
    i_employee_id IN t_employee_id,
    o_employees out sys_refcursor,
    o_locations out sys_refcursor) AS
  BEGIN
    OPEN o_employees FOR
      SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.email,
        e.phone_number,
        e.hire_date,
        e.job_id,
        j.job_title,
        e.salary,
        e.commission_pct,
        e.manager_id,
        (select first_name || ' ' || last_name from HR.EMPLOYEES WHERE employee_id = e.manager_id) manager_name,
        e.department_id,
        d.department_name
      FROM 
        HR.EMPLOYEES e 
      JOIN 
        HR.JOBS j on e.job_id = j.job_id
      JOIN HR.DEPARTMENTS d on e.department_id = d.department_id
      WHERE 
        e.employee_id = i_employee_id;
    
    OPEN o_locations FOR
      SELECT 
        l.location_id,
        l.street_address,
        l.postal_code,
        l.city,
        l.state_province,
        l.country_id
      FROM
        HR.LOCATIONS l
      WHERE 
        l.location_id = (
          select location_id
          from HR.DEPARTMENTS
          where department_id = 
            (select department_id from HR.EMPLOYEES WHERE EMPLOYEE_ID = i_employee_id)
          );      
  END load_employee;
  
  FUNCTION get_employee_manager(i_employee_id in t_employee_id) RETURN VARCHAR2
  IS
    v_manager_name VARCHAR2(46);
  BEGIN
    select 
      e.first_name || ' ' || e.last_name
    into
      v_manager_name
    from
      hr.employees e
    where 
      e.employee_id = (
        select 
          manager_id
        from
          HR.EMPLOYEES
        where
          employee_id = i_employee_id
        );
    return v_manager_name;
  END;

END EMPLOYEE_PACKAGE;
/
