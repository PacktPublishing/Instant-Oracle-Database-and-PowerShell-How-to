[void][System.Reflection.Assembly]::Load("Oracle.DataAccess, Version=2.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342")

function Select-TNS
{
    $enu = New-Object Oracle.DataAccess.Client.OracleDataSourceEnumerator
    Write-Output $enu.GetDataSources()
}

Select-TNS | where-object {$_.InstanceName -like '*DEV*'} | ft