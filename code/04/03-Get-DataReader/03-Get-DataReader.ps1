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

function Get-DataReader 
{
Param(
    [Parameter(Mandatory=$true)]
    [Oracle.DataAccess.Client.OracleConnection]$conn, 
    [Parameter(Mandatory=$true)]
    [string]$sql
)
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql,$conn)
    $reader = $cmd.ExecuteReader()    
    return ,$reader
}

$conn = Connect-Oracle (Get-ConnectionString)
$sql = "select city, state_province from locations order by city, state_province"
$reader = Get-DataReader $conn $sql

while ($reader.Read())
{
    $city = $reader.GetString($reader.GetOrdinal("city"))
    $stateProvince = $null
    
    if (!$reader.IsDBNull($reader.GetOrdinal("state_province")))
    {
        $stateProvince = $reader.GetString($reader.GetOrdinal("state_province"))
    }
    
    "City is '{0}', State/Province is '{1}'" -f $city, $stateProvince
}

$reader.Close()
$conn.Close()
