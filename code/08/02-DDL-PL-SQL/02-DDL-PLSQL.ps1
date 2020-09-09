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

$sql = @"
BEGIN
INSERT INTO HR.REGIONS (REGION_ID, REGION_NAME) VALUES (5, 'Africa');
INSERT INTO HR.COUNTRIES(COUNTRY_ID, COUNTRY_NAME, REGION_ID) VALUES ('BU','Burundi', 5);
END;
"@
Invoke-Oracle $conn $sql

Invoke-Oracle $conn "ALTER TABLE HR.DEPARTMENTS ADD NOTE VARCHAR2(100) NULL"
Invoke-Oracle $conn "ALTER TABLE HR.DEPARTMENTS DROP COLUMN NOTE"

$conn.Close(); $conn.Dispose()