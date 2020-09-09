[void][System.Reflection.Assembly]::Load("Oracle.DataAccess, Version=2.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342")

function New-Connection
{
    $dataSource = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=xe)))"
    $connectionString = ("Data Source={0};User Id=HR;Password=pass;Connection Timeout=10" -f $dataSource)
    New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
}

function New-ProcCommand ($procedure, $parameters)
{
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($procedure, (New-Connection))
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $cmd.BindByName = $true
    $parameters | foreach {$cmd.Parameters.Add($_) | Out-Null}    
    $cmd
}

function New-Param ($name, $type, $value, 
    $size = 0, $direction = [System.Data.ParameterDirection]::Input)
{
    New-Object Oracle.DataAccess.Client.OracleParameter($name, $type, $size) `
        -property @{Direction = $direction; Value = $value}
}

function Invoke-Proc ($procedure, $parameters)
{    
    $cmd = New-ProcCommand $procedure $parameters    
    if ($cmd.Connnection.State -ne [System.Data.ConnectionState]::Open) {$cmd.Connection.Open()}
    $cmd.ExecuteNonQuery() | Out-Null    
    $cmd.Connection.Close(); $cmd.Connection.Dispose(); $cmd.Dispose()
}

function Get-EmployeeManager ($employeeId)
{
    $params = @( 
        (New-Param -name "i_employee_id" -type ([Oracle.DataAccess.Client.OracleDbType]::Int32) -value $employeeId) 
        (New-Param -name "RETURN_VALUE" -type ([Oracle.DataAccess.Client.OracleDbType]::Varchar2) `
            -direction ([System.Data.ParameterDirection]::ReturnValue) -size 46)
    )
    Invoke-Proc "HR.EMPLOYEE_PACKAGE.get_employee_manager" $params
    $params[1].Value
}

"Manager of employee id 200 is {0}" -f (Get-EmployeeManager 200)