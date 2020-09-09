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

function Get-DataTable 
{
Param(
    [Parameter(Mandatory=$true)]
    [Oracle.DataAccess.Client.OracleConnection]$conn, 
    [Parameter(Mandatory=$true)]
    [string]$sql
)
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql,$conn)
    $da = New-Object Oracle.DataAccess.Client.OracleDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    [void]$da.Fill($dt)    
    # Prevent unrolling enumerable with ",$dt" if you want a DataTable returned
    return ,$dt
}

$conn = Connect-Oracle (Get-ConnectionString)
$dt = Get-DataTable $conn "select employee_id, first_name, last_name, hire_date from employees where job_id = 'SA_MAN'" 

# output the raw data
"Retrieved {0} records:" -f $dt.Rows.Count
$dt | ft -auto

# iterate through the data and do some processing
foreach ($dr in $dt.Rows)
{
    $eligible = [DateTime]::Now.AddYears(-5) -ge $dr.hire_date
    
    if ($eligible) 
    {
        Write-Output ("{0} {1} is eligible" -f $dr.first_name, $dr.last_name)
    }
}

$conn.Close()
