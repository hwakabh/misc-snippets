$childFileName = "childScript.ps1"
$childDirPath = "C:\Users\Administrator\Documents\misc-snippets\PowerShell\kick_vm_restart_remotely\childScripts"
$primaryChildIp = "172.16.110.248"
$secondaryChildIp = "172.16.110.29"
$scriptName = $PSCommandPath.Split('\')[-1]
$eventSrcName = "parentScript"

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

function showHelpMenu {
    Write-Host "----- Usage"
    Write-Host "Syntax: `n"
    Write-Host "`t $scriptName VIRTUAL_MACHINE_NAME`n"
    Write-Host "Arguments: `n"
    Write-Host "`tVIRTUAL_MACHINE_NAME : Name of virtual-machine to restart`n"
    Write-Host "Options: `n"
    Write-Host "`t--help | -h : Display help menu (this page)`n"
}

function testConnection ($target) {
    writeEvents -level "Information" -msg "Testing L4 connectivities with remote server [ $target ]"
    [Boolean] $isAlive = Test-NetConnection -ComputerName $target -Port 5985 -InformationLevel Quiet
    return $isAlive
}

function callChildScript ($target, $path, $vmname) {
    $isRemoteFileExist = Invoke-Command -ComputerName $target `
        -ScriptBlock { Test-Path $args[0] } `
        -ArgumentList $path
    if ($isRemoteFileExist -eq $true) {
        $msg = "Start to kick remote ps1 file [ $path ] on remote server [ $target ].`n
            Note that the virtual-machine [ $vmname ] would be restarted on hardware-level.
            "

#        Write-Host $msg

        writeEvents -level "Information" -msg $msg
        writeEvents -level "Information" -msg "Running command [ powershell.exe $path $vmname ] on $target ..."
        Invoke-Command -ComputerName $target `
            -ScriptBlock { powershell.exe $args[0] $args[1] } `
            -ArgumentList $path, $vmname
    } else {
#        Write-Host "Failed to confirm remote script existence."
        writeEvents -level "Error" -msg "childScript.ps1 does not exist on remote server, check path."
    }
    # TODO: getReturn codes and return to main function
}


if ($args.Length -eq 0) {
    Write-Host "ERROR : Missing arguments ..."
    Write-Host "Please provide a virtual-machine name.`n"
    showHelpMenu

} elseif ($args.Length -eq 1) {
    writeEvents -level "Information" -msg "Starting to main operation..."

    if (($args[0] -eq "--help") -or ($args[0] -eq "-h")) {
        showHelpMenu
        exit
    }

    if ((testConnection -target $primaryChildIp) -or (testConnection -target $secondaryChildIp)) {
        $filePath = Join-Path $childDirPath $childFileName
        $ErrorActionPreference = "stop"
        try {
            callChildScript -target $primaryChildIp -path $filePath -vmname $args[0]

        } catch {
 #           Write-Host "Failed to call script on primary server."
            writeEvents -level "Warning" `
                -msg "Failed to callChildScript on primary server, continue on secondary one ..."
            try {
                callChildScript -target $secondaryChildIp -path $filePath -vmname $args[0]

            } catch {
#                Write-Host "Failed to call script on secondary server."
                writeEvents -level "Error" `
                    -msg "Failed to kick childScript.ps1 both on primary/secondary."
                exit

            }
        }

        writeEvents -level "Information" `
            -msg "parentScript completed its task successfully, exit the program."
        exit

    } else {
        writeEvents -level "Error" `
            -msg "testConnection failed both of child servers, check the connectivity."
        exit

    }

} else {
    Write-Host "ERROR : Too many arguments..."
    Write-Host "Restarting multiple virutal-machines at once is not supported, provide just one.`n"
    showHelpMenu
}
