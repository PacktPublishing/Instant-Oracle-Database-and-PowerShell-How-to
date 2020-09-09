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

function Prompt-Password
{
    $securePass = Read-Host "Enter Password" -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass)
    $pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    $pass
}