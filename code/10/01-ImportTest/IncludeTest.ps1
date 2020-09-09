. .\Utilities.ps1
. .\Oracle.DataAccess.ps1

dir function: | ? {$_.Name -like '*ODP*'} | ft

Load-ODP -version 2
Select-ODPTypes | ? {$_.Name -like 'OracleCo*'} | ft

$conn = Connect-ODP (Get-ConfigConnectString .\App.config AppConnect)
$dt = Get-ODPDataTable $conn "select employee_id, first_name, last_name from employees where job_id = 'SA_MAN'" 
$dt | ft -auto
$conn.Close(); $conn.Dispose()