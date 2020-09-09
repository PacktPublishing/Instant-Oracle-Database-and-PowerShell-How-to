# load ODT.NET's Oracle.Management.Omo assembly
$odtAsmName = "Oracle.Management.Omo, Version=4.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342"
$asm = [Reflection.Assembly]::Load($odtAsmName)

# see what public types we have to work with in the assembly:
$types = $asm.GetTypes() | ? {$_.IsPublic}
$types | ? {$_.Name -like 'Con*'} | sort {$_.FullName } | ft -auto FullName

# see what properties we have on the Connection object
($types | ? {$_.Name -eq "Connection"}).GetProperties() `
    | sort {$_.Name} -desc | ft -auto Name, PropertyType

# now that we know the type and properties, create a conn object
$conn = New-Object Oracle.Management.Omo.Connection `
    -property @{UserID="HR"; Password = "pass"; TnsAlias = "LOCALDEV"}

# look at the connection methods we have to work with:
$conn | gm | ? {$_.MemberType -eq "Method"} | sort -desc {$_.Name} | ft -auto Name, Definition

# open connection and initialize
$conn.Open(); $conn.Initialize()

$tables = $conn.GetTables($false, $true)

# list tables
$tables | sort {$_.Name} | foreach {$_.Name}

# get a specific table and initialize it to dig deeper
$deptTable = $tables["DEPARTMENTS"]
$deptTable.Initialize()

# output column info on the DEPARTMENTS table
$deptTable.Columns | ft -auto Ordinal,Name, IsNullable, 
    @{Label="Type"; Expression={"{0} ({1})" -f $_.DataType.OracleType, $_.DataType.Size}}

# get create SQL statement for DEPARTMENTS table
$deptTable.GetCreateSQLs($true)[0]

$deptDS = $deptTable.GetData($true)
$deptDS.Tables["DEPARTMENTS"] | ? {$_.department_id -lt 40} | ft -auto DEPARTMENT_ID, DEPARTMENT_NAME

$conn.Close()
