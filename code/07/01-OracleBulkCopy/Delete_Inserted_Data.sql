delete from countries where region_id is null or region_id = 5;
delete from regions where region_id = 5;
commit;