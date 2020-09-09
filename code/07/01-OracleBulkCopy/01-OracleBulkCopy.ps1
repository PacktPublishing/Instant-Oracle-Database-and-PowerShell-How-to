#$ErrorActionPreference = "Stop"

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

function Get-ScriptDirectory
{ 
    if (Test-Path variable:\hostinvocation) 
    {
        $FullPath=$hostinvocation.MyCommand.Path
    }
    else
    {
        $FullPath=(get-variable myinvocation -scope script).value.Mycommand.Definition
    }
    if (Test-Path $FullPath)
    { 
        return (Split-Path $FullPath) 
    }
    else
    { 
        $FullPath=(Get-Location).path
        Write-Warning ("Get-ScriptDirectory: Powershell Host <" + $Host.name `
            + "> may not be compatible with this function, the current directory <" `
            + $FullPath + "> will be used.")
        return $FullPath
    }
}

$regionId = 5
$ds = New-Object System.Data.DataSet
$srcFilename = (join-path (Get-ScriptDirectory) countries.xml)
[void]$ds.ReadXml($srcFilename)
$regionCol = New-Object System.Data.DataColumn("REGION_ID", [int])
$regionCol.DefaultValue = $regionId
$regionCol.ColumnMapping = [System.Data.MappingType]::Attribute
$countryDT = $ds.Tables["country"]
$countryDT.Columns.Add($regionCol)

$conn = Connect-Oracle (Get-ConnectionString)
Add-Oracle $conn "INSERT INTO REGIONS (REGION_ID, REGION_NAME) VALUES ($regionId, 'Test Region')"

$bulkCopy = New-Object Oracle.DataAccess.Client.OracleBulkCopy($conn) `
    -property @{DestinationTableName = "COUNTRIES"; BulkCopyTimeout = 300; NotifyAfter = 50}
[void]$bulkCopy.ColumnMappings.Add("code", "country_id")
[void]$bulkCopy.ColumnMappings.Add("country_Text", "country_name")
[void]$bulkCopy.ColumnMappings.Add("region_id", "region_id")

Register-ObjectEvent -InputObject $bulkCopy -EventName OracleRowsCopied -SourceIdentifier BatchInserted `
    -MessageData $countryDT.Rows.Count -Action {
        $rowsCopied = $($event.sourceEventArgs.RowsCopied)
        $msg = "Inserted $rowsCopied records so far"
        $percentComplete = ($rowsCopied / $($event.MessageData) * 100)
        Write-Host $msg
        Write-Progress -Activity "Batch Insert" -Status $msg -PercentComplete $percentComplete
    } | Out-Null

$sw = [System.Diagnostics.StopWatch]::StartNew()
$bulkCopy.WriteToServer($countryDT)
$sw.Stop()
("Inserted {0} records total in {1:#0.000} seconds" -f $countryDT.Rows.Count, $sw.Elapsed.TotalSeconds)

Unregister-Event -SourceIdentifier BatchInserted
$bulkCopy.Dispose()
$conn.Close()
$conn.Dispose()