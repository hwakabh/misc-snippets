# Credentials
$VC = "vcsa01.nfvlab.local"
$USERNAME = "administrator@vsphere.local"
$PASSWORD = "VMware1!"

function showHelpMenu {
    Write-Host "WIP: Syntax here..."
}


function getVmPowerState ($vmname) {
    Write-Host "WIP: Functions of getting VM power state..."
    Write-Host "Getting power status of $vmname ..."
}

function restartVm ($vmname) {
    Write-Host "WIP: Functions of restarting VM power state..."
    Write-Host "Restarting $vmname ..."
}


# Connect-VIServer -Server $VC -User $USERNAME -Password $PASSWORD

# Check command line arguments
# ... Checking numbers of $args
if ($args.Length -eq 0) {
    Write-Host "ERROR: Please provide some arguments..."
    showHelpMenu
} elseif ($args.Length -eq 1) {
    # ... Checking contents of $args[0]
    if (($args[0] -eq "--help") -or ($args[0] -eq "-h")) {
        Write-Host "WIP: Help menu here..."
        showHelpMenu
    } else {
        Write-Host "Starting to operation : Log to eventvwr"
        getVmPowerState("SOME_VM_NAME")
        restartVm("SOME_VM_NAME")
        Write-Host "End operation."
    }
} else {
    Write-Host "ERROR: Too many arguments."
    showHelpMenu
} 
