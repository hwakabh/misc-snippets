$childFileName = "childScript.ps1"
$childDirPath = "C:\Users\Administrator\Documents"
$primaryChildIp = "172.16.110.248"
$secondaryChildIp = "172.16.110.29"


function showHelpMenu {
    Write-Host "WIP : help menu here..."
}

function testConnection ($target) {
    # TODO: Modify printing message not in stdout but eventvwr
    Write-Host "WIP : testing L4 connction."
    [Boolean] $isAlive = Test-NetConnection -ComputerName $target -Port 5985 -InformationLevel Quiet
    return $isAlive
}

function callChildScript ($target, $path) {
    Write-Host "WIP : kicking childScript [ $path ] on remote server [ $target ]"
    Invoke-Command -ComputerName $target -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $path
    # TODO: getReturn codes and return to main function
    # TODO: check file exists or not
}


if ($args.Length -eq 0) {
    Write-Host "ERROR : Missing Arguments."
    showHelpMenu

} elseif ($args.Length -eq 1) {
    Write-Host "INFO Starting to operation..."

    if (($args[0] -eq "--help") -or ($args[0] -eq "-h")) {
        showHelpMenu
        exit
    }

    if ((testConnection -target $primaryChildIp) -or (testConnection -target $secondaryChildIp)) {
        $filePath = Join-Path $childDirPath $childFileName
        $ErrorActionPreference = "stop"
        try {
            Write-Host "Trying to kick scripts remotely in primary server..."
            callChildScript -target $primaryChildIp -path $filePath

        } catch {
            Write-Host "WARNING : Failed to kick on primary server, continue on secondary one..."
            Write-Host "Trying to kick scripts remotely in secondary server..."

            try {
                callChildScript -target $secondaryChildIp -path $filePath

            } catch {
                Write-Host "ERROR : Failed to kick script both on primary/seconday ..."
                exit

            }
        }

        Write-Host $results
        Write-Host "parentScripts worked successfully."
        exit

#    } elseif (testConnection -target $secondaryChildIp) {
#        Write-Host "WARNING : Kick script on secondary childScript..."
#        exit

    } else {
        Write-Host "ERROR : Both of child unavailable..."
        # Write eventvwr to ERROR message.
        exit

    }

} else {
    Write-Host "ERROR : Too many arguments..."
    showHelpMenu
}
