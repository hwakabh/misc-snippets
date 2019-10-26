# Credentials
$VC = "vcsa01.nfvlab.local"
$USERNAME = "administrator@vsphere.local"
$PASSWORD = "VMware1!"

function writeEvents ($level, $msg) {
    Write-Host "WIP: Functions of writing event logs to eventvwr..."
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
if ($args.Length -eq 0) {
    Write-Host "ERROR: Please provide some arguments..."
    writeEvents("ERROR", "childScript.ps1 : The script was kicked without any arguments.")

} elseif ($args.Length -eq 1) {
    Write-Host "Starting to operation : Log to eventvwr"
    writeEvents("INFO", "childScript.ps1 : The script accepted proper argument, starting main operations...")
    getVmPowerState("SOME_VM_NAME")
    restartVm("SOME_VM_NAME")
    writeEvents("INFO", "childScript.ps1 : The script worked completely. Exit the program.")

} else {
    Write-Host "ERROR: Too many arguments."
    writeEvents("ERROR", "childScript.ps1 : Too many arguments were provided unexpectedly.")
} 
