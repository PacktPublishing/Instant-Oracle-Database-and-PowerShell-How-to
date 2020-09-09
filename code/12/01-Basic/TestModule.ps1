Import-Module Oracle.DataAccess -Prefix Oracle -ArgumentList 2

Get-Command -Module Oracle.DataAccess | ft -auto

Get-Help OracleConnect #-detailed | Out-String

Connect-OracleTNS LOCALDEV HR pass
OracleInvoke -sql "UPDATE HR.EMPLOYEES SET MANAGER_ID = 114 WHERE MANAGER_ID = 108" -WhatIf
OracleDisconnect -verbose

Remove-Module Oracle.DataAccess