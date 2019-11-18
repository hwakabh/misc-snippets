# Credentials
# NOTE: this scripts pre-requires password.secret file generated with Get-Credential cmdlet
$projectRootPath = Split-Path $MyInvocation.MyCommand.Path -Parent
Write-Host ">>> Project Root Path : $projectRootPath"
$passwordFilePath = Join-Path -Path $projectRootPath -ChildPath "vcenter.secret"
Write-Host ">>> Password file path : $passwordFilePath "
# Event source name is same as script filename itself
$eventSrcName = $PSCommandPath.Split('\')[-1]

$vCenter = "vcsa01.nfvlab.local"
$username = "administrator@vsphere.local"
$password = Get-Content $passwordFilePath | ConvertTo-SecureString
$credential = New-Object -TypeName System.Management.Automation.PsCredential `
    -ArgumentList $username, $password

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

function getVmPowerState ([String] $vmname) {
    writeEvents -level "Information" -msg "Getting power status of virtual-machine [ $vmname ] ..."
    Get-VM -Name $vmname
    return $?
}

function restartVm ([String] $vmname) {
    Write-Host "Restarting VM [ $vmname ]"
    writeEvents -level "Information" -msg "Restarting virtual-machine [ $vmname ] ..."
    Restart-VM -VM $vmname -Confirm:$false
    return $?
}



# Check command line arguments
if ($args.Length -eq 0) {
    writeEvents -level "Error" -msg "The script was kicked without any arguments."
    Write-host "The script was kicked without any arguments."
    exit 255

} elseif ($args.Length -eq 1) {
    Write-Host "The Script accepted proper argument, staring main script..."
    writeEvents -level "Information" -msg "The script accepted proper argument, starting main operations..."

    try {
        Connect-VIServer -Server $vCenter -Credential $credential |Out-Null
        writeEvents -level "Information" -msg "Successfully connected vCenter Server [ $vCenter ]"
    } catch {
#        Disconnect-VIServer -Server $vCenter -Confirm:$false
        Write-Host "Failed to connect vCenter Server ..."
        writeEvents -level "Error" -msg "Failed to connect vCenter Server [ $vCenter ]. Exit the program."
        exit 128
    }

    if ($(getVmPowerState -vmname $args[0]) -eq $false) {
        Disconnect-VIServer -Server $vCenter -Confirm:$false
        Write-Host "VM [ $($args[0]) ] not found on vCenter, exit the program without any operations..."
        writeEvents -level "Error" -msg "virutal-machine [ $($args[0]) ] not found on vCenter [ $vCenter ], exit the program without any operations..."
        exit 1
    } else {
        $ret = restartVm -vmname $args[0]
        if ($(restartVm -vmname $args[0]) -eq $false) {
            Write-Host "Tried to restart VM [ $($args[0]) ] , but failed."
            writeEvents -level "Error" -msg "Tried to restart VM, but failed unexpectedly."
            Disconnect-VIServer -Server $vCenter -Confirm:$false
            exit 1
        } else {
            Write-Host "Successfully restart VM [ $($args[0]) ], current VM power state below."
            Write-Host ">>>>>> `n"
            # Without retuning any boolean value to stdout.
            Get-VM -Name $args[0]
            Write-Host "`n<<<<<<"
            writeEvents -level "Information" -msg "The script worked completely. Exit the program."
            exit 0
        }
    }

} else {
    Write-Host "Too many argument were provied unexpectedly."
    writeEvents -level "Error" -msg "Too many arguments were provoded unexpectedly."
    exit 255

} 
