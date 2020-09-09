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
    
    if ($cmd.Connnection.State -ne [System.Data.ConnectionState]::Open)
    {
        $cmd.Connection.Open()
    }   

    $cmd.ExecuteNonQuery() | Out-Null    
    $cmd.Connection.Close(); $cmd.Connection.Dispose(); $cmd.Dispose()
}

function New-Employee ($firstName, $lastName, $email, $jobId, $hireDate)
{
    $procedure = "HR.EMPLOYEE_PACKAGE.INSERT_EMPLOYEE"
    $params = @( 
        (New-Param -name "O_EMPLOYEE_ID" -type ([Oracle.DataAccess.Client.OracleDbType]::Int32) `
            -direction ([System.Data.ParameterDirection]::Output)) 
        (New-Param -name "I_FIRST_NAME" -type ([Oracle.DataAccess.Client.OracleDbType]::Varchar2) -value $firstName) 
        (New-Param -name "I_LAST_NAME" -type ([Oracle.DataAccess.Client.OracleDbType]::Varchar2) -value $lastName) 
        (New-Param -name "I_EMAIL" -type ([Oracle.DataAccess.Client.OracleDbType]::Varchar2) -value $email) 
        (New-Param -name "I_JOB_ID" -type ([Oracle.DataAccess.Client.OracleDbType]::Varchar2) -value $jobId) 
        (New-Param -name "I_HIRE_DATE" -type ([Oracle.DataAccess.Client.OracleDbType]::Date) -value $hireDate)
    )
    Invoke-Proc $procedure $params
    $employeeId = $params[0].Value
    $employeeId
}

$employeeId = New-Employee -firstName "John" -lastName "Doe" -email "johndoe@domain.com" `
    -jobId "HR_REP" -hireDate (Get-Date)
"Inserted new employee with id $employeeId"