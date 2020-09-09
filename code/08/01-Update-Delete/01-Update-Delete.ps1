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

function Invoke-Oracle 
{
Param(
    [Parameter(Mandatory=$true)][Oracle.DataAccess.Client.OracleConnection]$conn, 
    [Parameter(Mandatory=$true)][string]$sql,        
    [Parameter(Mandatory=$false)][System.Collections.Hashtable]$paramValues,
    [Parameter(Mandatory=$false)][switch]$passThru
) 
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql,$conn)
    $cmd.BindByName = $true
    
    if ($paramValues)
    {
        foreach ($p in $paramValues.GetEnumerator())
        {
            $oraParam = New-Object Oracle.DataAccess.Client.OracleParameter
            $oraParam.ParameterName = $p.Key
            $oraParam.Value = $p.Value
            $cmd.Parameters.Add($oraParam) | Out-Null
        }
    }   
    
    $result = $cmd.ExecuteNonQuery()      
    $cmd.Dispose()
    
    if ($passThru) { $result }
}

$conn = Connect-Oracle (Get-ConnectionString)

$affected = Invoke-Oracle $conn -PassThru `
    "UPDATE HR.JOBS SET MIN_SALARY = MIN_SALARY + 1000 WHERE UPPER(JOB_TITLE) LIKE '%MANAGER%'" 
"Updated {0} job record(s)" -f $affected    

$cities = "Jacksonville", "Orlando", "Tampa", "Miami", "Del Ray Beach"
$inserted = 0
foreach ($city in $cities) {
    $inserted += Invoke-Oracle $conn "INSERT INTO HR.LOCATIONS (LOCATION_ID, CITY, STATE_PROVINCE) `
        VALUES (HR.LOCATIONS_SEQ.NEXTVAL, :CITY, :STATE_PROVINCE)" `
        @{ 'CITY'=$city; 'STATE_PROVINCE'='Florida' } -PassThru
}   

"Inserted $inserted location records"

Invoke-Oracle $conn "UPDATE HR.LOCATIONS SET COUNTRY_ID = `
    (SELECT COUNTRY_ID FROM HR.COUNTRIES WHERE COUNTRY_NAME = 'United States of America')"

"Deleted {0} location records" -f (Invoke-Oracle $conn `
    "DELETE FROM LOCATIONS WHERE STATE_PROVINCE = 'Florida'" -PassThru)   
   
$conn.Close(); $conn.Dispose()