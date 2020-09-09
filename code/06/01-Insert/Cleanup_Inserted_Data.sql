/*
select * from employees where last_name = 'De Mase';
select * from jobs where job_id = 'CFO';
select * from countries where country_id = 'BG';
*/

ALTER TRIGGER SECURE_EMPLOYEES DISABLE;
delete from employees where last_name = 'De Mase';
ALTER TRIGGER SECURE_EMPLOYEES ENABLE;

delete from countries where country_name = 'Bulgaria';
delete from jobs where job_id = 'CFO';

commit;