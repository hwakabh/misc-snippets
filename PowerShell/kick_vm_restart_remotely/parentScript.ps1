$childFileName = "childScript.ps1"
$childDirPath = "C:\Users\Administrator"
$primaryChildIp = "172.16.110.29"
$secondaryChildIp = "172.16.110.248"


function showHelpMenu {
    Write-Host "WIP : help menu here..."
}

function testConnection ($target) {
    # TODO: Modify printing message not in stdout but eventvwr
    Write-Host "WIP : testing L4 connction."
    [Boolean] $isAlive = Test-NetConnection -ComputerName $target -Port 5985 -InformationLevel Quiet
    return $isAlive
}

function callChildScript ($filepath) {
    Write-Host "WIP : kicking childScript remotely..."
    # with Invoke-Command cmdlet
    # TODO: getReturn codes and return to main function
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

    if (testConnection -target $primaryChildIp) {
        Write-Host "INFO : Kick script on primary childScript ..."
        exit
    } elseif (testConnection -target $secondaryChildIp) {
        Write-Host "WARNING : Kick script on secondary childScript..."
        exit
    } else {
        Write-Host "ERROR : Both of child unavailable..."
        # Write eventvwr to ERROR message.
        exit
    }

} else {
    Write-Host "ERROR : Too many arguments..."
    showHelpMenu
}
