[void][System.Reflection.Assembly]::Load("Oracle.DataAccess, Version=2.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342")

function Connect-Oracle([string] $connectionString = $(throw "connectionString is required"))
{
    $conn= New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
    $conn.Open()    
    Write-Output $conn
}

function Get-ConnectionString
{
    $dataSource = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=xe)))"
    Write-Output ("Data Source={0};User Id=HR;Password=pass;Connection Timeout=10" -f $dataSource)
}

$conn = Connect-Oracle (Get-ConnectionString)

$sql = "SELECT EMPLOYEE_ID, MANAGER_ID, SALARY FROM HR.EMPLOYEES WHERE DEPARTMENT_ID = 90"
$cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql,$conn)
$da = New-Object Oracle.DataAccess.Client.OracleDataAdapter($cmd)
$cmdBuilder = new-object Oracle.DataAccess.Client.OracleCommandBuilder $da 
$dt = New-Object System.Data.DataTable
[void]$da.Fill($dt)

foreach ($dr in $dt.Rows) {
    if ($dr.manager_id -eq 100) {$dr.salary += $dr.salary * .10}
}

"Updated {0} records" -f $da.Update($dt)

$cmdBuilder.Dispose(); $da.Dispose(); $cmd.Dispose()
$conn.Close(); $conn.Dispose()