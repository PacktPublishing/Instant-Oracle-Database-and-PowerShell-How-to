function Get-ConfigConnectionString(
    [string] $filename = $(throw "filename is required"),
    [string] $name = $(throw "connection string name is required"))
{
    $config = [xml](gc $filename)
    $item = $config.configuration.connectionStrings.add | where {$_.name -eq $name}
    if (!$item) { throw "Failed to find a connection string with name '{0}'" -f $name}
    return $item.connectionString
}

$connectString = Get-ConfigConnectionString .\App.config AppConnect
Write-Output "Connection string is:  $connectString"