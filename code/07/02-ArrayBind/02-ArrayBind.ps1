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

$conn = Connect-Oracle (Get-ConnectionString)

$regions = Import-CSV (join-path (Get-ScriptDirectory) Regions.csv)
$regionIds = New-Object int[] $regions.Count
$regionNames = New-Object string[] $regions.Count
$index = 0

foreach ($r in $regions) {
    $regionIds[$index] = $r.RegionId; $regionNames[$index++] = $r.RegionName
}

$cmd = New-Object Oracle.DataAccess.Client.OracleCommand( `
    "insert into regions values (:region_id, :region_name)",$conn)
$idParam = $cmd.Parameters.Add(":region_id", [Oracle.DataAccess.Client.OracleDbType]::Int32)
$nameParam = $cmd.Parameters.Add(":region_name", [Oracle.DataAccess.Client.OracleDbType]::Varchar2)
$idParam.Value = $regionIds; $nameParam.Value = $regionNames
$cmd.ArrayBindCount = $regions.Count
$trans = $conn.BeginTransaction()
$cmd.ExecuteNonQuery()
$trans.Commit()

$cmd.Dispose(); $conn.Close(); $conn.Dispose();