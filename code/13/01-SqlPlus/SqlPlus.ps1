function Invoke-Scripts($server, $user, $password) {
    "Running scripts for $user on $server"
    pushd $user
    $files = @(gci | where {!$_.PsIsContainer})
	$count = 0
	
    foreach ($file in $files) {        
        write-progress -activity "Running scripts for $user" `
			-currentoperation $file.name -status Executing `
			-PercentComplete (100*$count++/$files.count)
        Invoke-Script $server $user $password $file        
        New-Directory ".\Completed"
        move-item -path $file.fullname -destination ".\Completed" -Force
    }
    
    write-progress -activity "Running scripts for $user" `
        -status Complete -completed
    popd
    "Completed running $count script(s) for $user on $server"
}

function Invoke-Script($server, $user, $password, $file) {
    $logDir = ("..\Logs\{0}\{1}" -f $script:_dateId, $user)
    New-Directory $logDir
    $logFile = join-path $logDir ($file.basename + ".html")
    
    "Running $file against $user@$server"
    (Get-SqlPlusSQL $file.fullname) | sqlplus.exe -L -M "HTML ON SPOOL ON" `
		-S "$user/""$password""@$server" >> $logfile 2>$1
    "Ran $file against $user@$server. Details at $logfile"
    $script:_runCount++
    
    if ($LASTEXITCODE -ne 0) {
        write-error ("ERROR executing {0}!" -f $file.FullName)
        invoke-item $logFile; exit
    }
}

function Get-SqlPlusSQL($filename) {
@"
    whenever sqlerror exit sql.sqlcode
    set echo off
    set termout off
    $(cat $filename -readcount 0 | Out-String)
    commit;
    exit
"@
}

function Get-Password($user) {
    $pwd = read-host -AsSecureString "Password for $user@$server"
    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(`
		[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd))
}

function New-Directory($dir) {
    if (!(test-path $dir)) { 
        new-item $dir -type directory | Out-Null
    }
}

function Get-ScriptDirectory { 
    if (Test-Path variable:\hostinvocation) { $FullPath=$hostinvocation.MyCommand.Path }
    else { $FullPath=(get-variable myinvocation -scope script).value.Mycommand.Definition }
    if (Test-Path $FullPath) { return (Split-Path $FullPath) }
    else
    { 
        $FullPath=(Get-Location).path
        Write-Warning ("Get-ScriptDirectory: Powershell Host <" + $Host.name `
            + "> may not be compatible with this function, the current directory <" `
            + $FullPath + "> will be used.")
        $FullPath
    }
}

function Main {   
    $server = read-host "Server TNS name"
    pushd (Get-ScriptDirectory)
    $userDirs = @(gci | ? {$_.PsIsContainer -and $_.Name -ne "Logs"})
    
    foreach ($dir in $userDirs) {
        $user = $dir.Name
        $password = Get-Password($user)        
        $sw = [System.Diagnostics.StopWatch]::StartNew()
        $runCountBefore = $script:_runCount
        Invoke-Scripts $server $user $password
        $sw.Stop()
        "Ran $($script:_runCount - $runCountBefore) script(s) " +
            "for $user@$server in $($sw.Elapsed.TotalSeconds) second(s)"
    }
    
    popd    
    "Finished. Ran $script:_runCount script(s) total"
}

$script:_dateId = "{0:MM-dd-yyyy.hh-mm-ss}" -f (Get-Date)
$script:_runCount = 0
Main