function Get-CanTranscribe
{
    return (!((Get-Host).Name -eq "Windows PowerShell ISE Host"))
} 

function Get-ConfigConnectString
{
Param( [Parameter(Mandatory=$true)] [string]$filename, 
       [Parameter(Mandatory=$true)] [string]$name )
    $config = [xml](cat $filename)
    $item = $config.configuration.connectionStrings.add | where {$_.name -eq $name}
    if (!$item) { throw "Failed to find a connection string with name '{0}'" -f $name}
    $item.connectionString
}

function Get-MachineConfigConnectString
{
Param( [Parameter(Mandatory=$true)] [string]$name )
    # %WINDIR%\Microsoft.NET\Framework\<Version>\Config
    $config = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()  
    $item = $config.ConnectionStrings.ConnectionStrings[$name]
    if (!$item) { throw "Failed to find a connection string with name '{0}'" -f $name}
    $item.ConnectionString
}

function Prompt-Password
{
    $securePass = Read-Host "Enter Password" -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
    $pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    $pass
}