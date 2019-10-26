# Credentials
$VC = "vcsa01.nfvlab.local"
$USERNAME = "administrator@vsphere.local"
$PASSWORD = "VMware1!"
$eventSrcName = "childScript"

# Logging Properties : Create Event source if not exist
if ((Get-ChildItem -Path HKLM:SYSTEM\CurrentControlSet\Services\EventLog\Application | `
    Select-String $eventSrcName) -eq $null) {
    New-EventLog -LogName Application -Source $eventSrcName
    Write-EventLog -LogName Application -Source $eventSrcName -EntryType Information -EventId 1001 `
        -Message "Event Source $eventSrcName not found, created."
} else {
    Write-EventLog -LogName Application -Source $eventSrcName -EntryType Information -EventId 1001 `
        -Message "Event Source $eventSrcName has already exited."
}


function writeEvents ([String] $level, [String] $msg) {
    $id = 0
    if ($level -eq "Error") {
        $id = 901
    } elseif ($level -eq "Warning") {
        $id = 801
    } elseif ($level -eq "Information") {
        $id = 1001
    }

    if ($id -ne 0) {
        Write-EventLog -LogName Application -Source $eventSrcName `
            -EntryType $level `
            -EventId $id `
            -Message $msg
    } else {
        Write-Host "EventID not accepted."
    }
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
    writeEvents -level "Error" -msg "The script was kicked without any arguments."
    exit

} elseif ($args.Length -eq 1) {
    writeEvents -level "Information" -msg "The script accepted proper argument, starting main operations..."


    getVmPowerState("SOME_VM_NAME")
    restartVm("SOME_VM_NAME")
    writeEvents -level "Information" -msg "The script worked completely. Exit the program."
    exit

} else {
    writeEvents -level "Error" -msg "Too many arguments were provoded unexpectedly."
    exit

} 
