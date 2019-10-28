# This Script would be used as CP, Contingency Plan, in case of vCenter Isssues.
# The Script try to connect ESXi hosts directly instead of vCenter Server.

# Credentials
# NOTE: this scripts pre-requires password.secret file generated with Get-Credential cmdlet
$passwordFilePath = Join-Path (Get-Location).Path "password.secret"
$vCenter = "vcsa01.nfvlab.local"
$username = "administrator@vsphere.local"
$password = Get-Content $passwordFilePath | ConvertTo-SecureString
$credential = New-Object -TypeName System.Management.Automation.PsCredential `
    -ArgumentList $username, $password
$eventSrcName = "childScript"


# Logging Properties : Create Event source if not exist
if ((Get-ChildItem -Path HKLM:SYSTEM\CurrentControlSet\Services\EventLog\Application | `
    Select-String $eventSrcName) -eq $null) {
    New-EventLog -LogName Application -Source $eventSrcName
    Write-EventLog -LogName Application -Source $eventSrcName -EntryType Information -EventId 1001 `
        -Message "Event Source $eventSrcName not found, created."
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
    writeEvents -level "Information" -msg "Getting power status of virtual-machine [ $vmname ] ..."
    Get-VM -Name $vmname
    return $?
}

function restartVm ($vmname) {
    writeEvents -level "Information" -msg "Restarting virtual-machine [ $vmname ] ..."
    Restart-VM -VM $vmname -Confirm:$false
    return $?
}



# Check command line arguments
if ($args.Length -eq 0) {
    writeEvents -level "Error" -msg "The script was kicked without any arguments."
    exit

} elseif ($args.Length -eq 1) {
    writeEvents -level "Information" -msg "The script accepted proper argument, starting main operations..."

    try {
        Connect-VIServer -Server $vCenter -Credential $credential |Out-Null
        writeEvents -level "Information" -msg "Successfully connected vCenter Server [ $vCenter ]"
    } catch {
#        Disconnect-VIServer -Server $vCenter -Confirm:$false
        writeEvents -level "Error" -msg "Failed to connect vCenter Server [ $vCenter ]. Exit the program."
        exit
    }

    if ($(getVmPowerState -vmname $args[0]) -eq $false) {
        Disconnect-VIServer -Server $vCenter -Confirm:$false
        writeEvents -level "Error" -msg "virutal-machine [ $args[0] ] not found on vCenter [ $vCenter ]"
        exit
    } else {
        if ((restartVm -vmname $args[0]) -eq $false) {
            writeEvents -level "Error" -msg "Tried to restart VM, but failed unexpectedly."
            Disconnect-VIServer -Server $vCenter -Confirm:$false
            exit
        } else {
            writeEvents -level "Information" -msg "The script worked completely. Exit the program."
            exit
        }
    }

} else {
    writeEvents -level "Error" -msg "Too many arguments were provoded unexpectedly."
    exit

} 
