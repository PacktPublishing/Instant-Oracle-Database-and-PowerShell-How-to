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

function Connect-ODP
{
Param( [Parameter(Mandatory=$true)] [string]$connectionString )
    $conn= New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
    $conn.Open()
    $conn
}

function Get-ODPAssemblyName
{
param ( [Parameter(Mandatory=$true)][validateset(2,4)]
        [int] $version)
    $a = @{}
    $a["2"] = "Oracle.DataAccess, Version=2.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342"
    $a["4"] = "Oracle.DataAccess, Version=4.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342"
    $a[$version.ToString()]
}

function Get-ODPAssembly
{
    [appdomain]::currentdomain.getassemblies() `
        | ? {$_.FullName -like 'Oracle.DataAccess,*'} `
        | select -first 1
}

function Get-ODPDataReader 
{
Param(
    [Parameter(Mandatory=$true)]
    [Oracle.DataAccess.Client.OracleConnection]$conn, 
    [Parameter(Mandatory=$true)]
    [string]$sql
)
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql,$conn)
    $reader = $cmd.ExecuteReader()    
    ,$reader
}

function Get-ODPDataTable 
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
    ,$dt
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

function Load-ODP
{
param (
    [Parameter(Position=0, Mandatory=$true)]
    [validateset(2,4)]
    [int] $version, 
    [Parameter(Position=1)]
    [switch] $passThru
)
    $asm = [System.Reflection.Assembly]::Load((Get-ODPAssemblyName $version))
    if ($passThru) { $asm }
}

function New-ODPCursorParam ($name)
{    
    New-Param -name $name -type ([Oracle.DataAccess.Client.OracleDbType]::RefCursor) `
        -direction ([System.Data.ParameterDirection]::Output)
}

function New-ODPParam ($name, $type, $value, 
    $size = 0, $direction = [System.Data.ParameterDirection]::Input)
{
    New-Object Oracle.DataAccess.Client.OracleParameter($name, $type, $size) `
        -property @{Direction = $direction; Value = $value}
}

function Select-ODPTNS
{
    $enu = New-Object Oracle.DataAccess.Client.OracleDataSourceEnumerator
    $enu.GetDataSources()
}

function Select-ODPTypes
{
    (Get-ODPAssembly).GetTypes() | ? {$_.IsPublic} | sort {$_.FullName }
}