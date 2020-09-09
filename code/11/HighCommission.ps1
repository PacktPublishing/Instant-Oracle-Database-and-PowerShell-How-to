param (
[Parameter(Mandatory=$true)][string]$outputPath,
[Parameter(Mandatory=$false)][decimal]$commissionThreshold = .25)

$errorActionPreference = "Continue"

function Get-ScriptDirectory
{ 
    if (Test-Path variable:\hostinvocation) { $FullPath=$hostinvocation.MyCommand.Path }
    else { $FullPath=(get-variable myinvocation -scope script).value.Mycommand.Definition }
    if (Test-Path $FullPath) { return (Split-Path $FullPath) }
    else
    { 
        $FullPath=(Get-Location).path
        Write-Warning ("Get-ScriptDirectory: Powershell Host <" + $Host.name `
            + "> may not be compatible with this function, the current directory <" `
            + $FullPath + "> will be used.")
        return $FullPath
    }
}

function Set-HostSettings
{    
    if ($Host -and $Host.UI -and $Host.UI.RawUI) {
        $ui = (Get-Host).UI.RawUI
        $winSize = $ui.WindowSize; $buffSize = $ui.BufferSize
        $buffSize.Width = 120; $ui.BufferSize = $buffSize
        $winSize.Width = 120; $ui.WindowSize = $winSize
    }
}

function Invoke-Script
{
    try {Set-HostSettings} catch {}
    "Processing started. Commission threshold is $commissionThreshold, output path is $outputPath"
    
    "Checking existence of output path $outputPath"
    if (!(Test-Path $outputPath -PathType Container)) { 
        throw "outputPath '$outputPath' doesn't exist"
    }
    
    "Importing Oracle.DataAccess.ps1"
    . (join-path $_scriptDir Oracle.DataAccess.ps1)
    
    $sqlFilename = (join-path $_scriptDir Query.sql)
    $configFile = (join-path $_scriptDir App.config)
    $outputFilename = (join-path $outputPath HighCommission.csv)
    
    if (Test-Path($outputFilename)) {
        "Removing old copy of $outputFilename"
        Remove-Item $outputFilename -Force
    }
    
    "Loading ODP.NET 2x"; $asm = Load-ODP -version 2 -passthru 
    "Loaded {0}" -f $asm.FullName
    
    "Reading SQL from $sqlFilename"    
    $sql = (Get-Content $sqlFilename -EV err) | Out-String
    if ($err) { 
        Write-Warning "SQL read failed; bailing"; throw $err 
    }
    $sql
    
    "Reading connection string from $configFile"
    $connectString = (Get-ConfigConnectString $configFile AppConnect)
    "Connecting with $connectString"
    $conn = Connect-ODP $connectString

    try {
        "Running SQL using threshold of $commissionThreshold"
        $dt = Get-ODPDataTable $conn $sql @{ 'commission_threshold' = $commissionThreshold; }
        
        "Retrieved {0} record(s):" -f $dt.Rows.Count
        $dt | ft -auto
        
        "Exporting data to $outputFilename"
        $dt | Export-CSV -NoTypeInformation $outputFilename
        $dt.Dispose()
    }
    catch [System.Exception] {
        throw "Failed to run SQL: " + $_.Exception.ToString()
    }
    finally {
        "Closing connection"
        $conn.Close(); $conn.Dispose()
    }    
}

try {
    $script:_scriptDir = (Get-ScriptDirectory)
    . (join-path $_scriptDir Utilities.ps1)
    
    if (Get-CanTranscribe) {
        try { Stop-Transcript | out-null } catch { }
        Start-Transcript -path (join-path $_scriptDir "HighCommissionLog.txt")
    }

    Invoke-Script
}
catch [System.Exception] {
    $error = ("Script failed with error: {0}{1}{1}Script: {2}  Line,Col: {3},{4}" `
        -f $_.Exception.ToString(), [Environment]::NewLine,  $_.InvocationInfo.ScriptName, `
        $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine)
    Write-Error $error; Exit 100
}
finally {
    if (Get-CanTranscribe) { Stop-Transcript }
}
