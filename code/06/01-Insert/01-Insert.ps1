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

function Add-Oracle 
{
Param(
    [Parameter(Mandatory=$true)][Oracle.DataAccess.Client.OracleConnection]$conn, 
    [Parameter(Mandatory=$true)][string]$sql,        
    [Parameter(Mandatory=$false)][System.Collections.Hashtable]$paramValues,
    [Parameter(Mandatory=$false)][string]$idColumn
) 
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql,$conn)
    $cmd.BindByName = $true
    $idParam = $null
    
    if ($idColumn)
    {
        $cmd.CommandText = "{0} RETURNING {1} INTO :{2} " -f $cmd.CommandText, $idColumn, $idColumn
        $idParam = New-Object Oracle.DataAccess.Client.OracleParameter
        $idParam.Direction = [System.Data.ParameterDirection]::Output
        $idParam.DbType = [System.Data.DbType]::Int32
        $idParam.Value = [DBNull]::Value
        $idParam.SourceColumn = $idColumn
        $idParam.ParameterName = $idColumn
        $cmd.Parameters.Add($idParam) | Out-Null
    }
    
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
    
    if ($idParam)
    {
        if ($idParam.Value -ne [DBNull]::Value) { $idParam.Value } else { $null }
        $idParam.Dispose()
    }
    
    $cmd.Dispose()    
}

function Add-Employee(
    [Parameter(Mandatory=$true)][string]$firstName, 
    [Parameter(Mandatory=$true)][string]$lastName, 
    [Parameter(Mandatory=$true)][string]$email, 
    [Parameter(Mandatory=$true)][DateTime]$hireDate,
    [Parameter(Mandatory=$true)][string]$jobId,
    [Parameter(Mandatory=$false)][string]$phoneNumber
)
{
    $params = @{ 'FIRST_NAME'=$firstName; 'LAST_NAME'=$lastName; 'EMAIL'=$email; `
        'HIRE_DATE'=$hireDate; 'JOB_ID'=$jobId; 'PHONE_NUMBER'=$phoneNumber }
         
    $sql = @"
INSERT INTO EMPLOYEES (
    EMPLOYEE_ID, 
    FIRST_NAME, 
    LAST_NAME, 
    EMAIL, 
    HIRE_DATE, 
    JOB_ID,
    PHONE_NUMBER)
VALUES (
    EMPLOYEES_SEQ.NEXTVAL, 
    :FIRST_NAME, 
    :LAST_NAME, 
    :EMAIL,
    :HIRE_DATE, 
    :JOB_ID,
    :PHONE_NUMBER
)
"@
    $employeeId = Add-Oracle $script:conn $sql $params EMPLOYEE_ID
    $employeeId
}

$conn = Connect-Oracle (Get-ConnectionString)

Add-Oracle $conn "INSERT INTO JOBS (JOB_ID,JOB_TITLE) VALUES ('CFO', 'Chief Financial Officer')" 

$employeeId = Add-Employee -firstName "Joe" -lastName "De Mase" -email "joe@company.com" `
    -hireDate ([DateTime]::Now.Date) -jobId "CFO"    
if ($employeeId) { "Added employee; new id is $employeeId" }

Add-Oracle $conn `
    "INSERT INTO COUNTRIES (COUNTRY_ID,COUNTRY_NAME,REGION_ID) VALUES (:COUNTRY_ID, :COUNTRY_NAME, :REGION_ID)" `
    @{ 'COUNTRY_ID'='BG'; 'COUNTRY_NAME'='Bulgaria'; 'REGION_ID'=1; }

$conn.Close()
$conn.Dispose()