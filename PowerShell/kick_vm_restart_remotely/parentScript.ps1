$childFileName = "childScript.ps1"
$childDirPath = "C:\Users\Administrator"
$primaryChildIp = "172.16.110.29"
$secondaryChildIp = "172.16.110.248"


function showHelpMenu {
    Write-Host "WIP : help menu here..."
}

function testConnection ($target) {
    Write-Host "WIP : testing L4 connction."
    # with TestNetConnection cmdlet
    # return: Boolean value whether it could be connected or not
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
    if (testConnection($primaryChildIPp)) {
        Write-Host "INFO : Kick script on rimary childScript ..."
        # sys.exit()
    elseif (testConnection($secondaryChildIp)) {
        Write-Host "WARNING : Kick script on secondary childScript..."
        # sys.exit()
    else {
        Write-Host "ERROR : Both of child unavailable..."
        # Write eventvwr to ERROR message.
        # sys.exit()
} else {
    Write-Host "ERROR : Too many arguments..."
    showHelpMenu
}
