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

function New-CursorParam ($name)
{    
    New-Param -name $name -type ([Oracle.DataAccess.Client.OracleDbType]::RefCursor) `
        -direction ([System.Data.ParameterDirection]::Output)
}

function Get-ProcDataSet ($procedure, $parameters)
{    
    $cmd = New-ProcCommand $procedure $parameters
    
    if ($cmd.Connnection.State -ne [System.Data.ConnectionState]::Open)
    {
        $cmd.Connection.Open()
    }
    
    $da = New-Object Oracle.DataAccess.Client.OracleDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
  
    $cmd.ExecuteNonQuery() | Out-Null
   
    $cursors = $cmd.Parameters `
        | Where-Object {$_.OracleDbType -eq [Oracle.DataAccess.Client.OracleDbType]::RefCursor} `
        | foreach {
            $dt = $ds.Tables.Add($_.ParameterName)
            $cursor = [Oracle.DataAccess.Types.OracleRefCursor]$_.Value
            $da.Fill($dt, $cursor) | Out-Null
          }    
    
    $cmd.Connection.Close(); $cmd.Connection.Dispose(); $cmd.Dispose()
    $ds
}

function Get-EmployeeDataSet ($employeeId)
{
    $procedure = "HR.EMPLOYEE_PACKAGE.LOAD_EMPLOYEE"
    $params = @( 
        (New-Param -name "I_EMPLOYEE_ID" -type ([Oracle.DataAccess.Client.OracleDbType]::Int32) -value $employeeId) 
        (New-CursorParam -name "O_EMPLOYEES") 
        (New-CursorParam -name "O_LOCATIONS") 
    )
    $ds = Get-ProcDataSet $procedure $params
    $ds
}

$ds = Get-EmployeeDataSet -employeeId 203
$ds.Tables["O_EMPLOYEES"]
$ds.Tables["O_LOCATIONS"]
$ds.Dispose()