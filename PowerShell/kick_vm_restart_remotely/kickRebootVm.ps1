$lines = Get-Content .\settings.txt
foreach ($line in $lines) {
    if($line -match "^$"){ continue }
    if($line -match "^\s*;"){ continue }

    $key, $value = $line.split(' = ', 2)
    Invoke-Expression "`$$key='$value'"
}

$scriptName = $PSCommandPath.Split('\')[-1]
$scriptPath = Convert-Path .
$childFileName = "rebootVm.ps1"
$childDirPath = Join-Path -Path $scriptPath -ChildPath "childScripts\"

Write-Host ">>> Script [ $scriptName ] started, reading parameters."
Write-Host ">>> Set Primary remote server [ $primaryChildIp ]"
Write-Host ">>> Set Secondary remote server [ $secondaryChildIp ]"
Write-Host ">>> Determined path of child script [ $childFileName ]`n $childDirPath"

# Logging Properties : Create Event source if not exist
if ((Get-ChildItem -Path HKLM:SYSTEM\CurrentControlSet\Services\EventLog\Application | `
    Select-String $scriptName) -eq $null) {
    New-EventLog -LogName Application -Source $scriptName
    Write-EventLog -LogName Application -Source $scriptName -EntryType Information -EventId 1001 `
        -Message "Event Source $scriptName not found, created."
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
        Write-EventLog -LogName Application -Source $scriptName `
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

function testConnection ([String] $target) {
    writeEvents -level "Information" -msg "Testing L4 connectivities with remote server [ $target ]"
    [Boolean] $isAlive = Test-NetConnection -ComputerName $target -Port 5985 -InformationLevel Quiet
    return $isAlive
}

function callChildScript ([String] $target,[String] $path, [String] $vmname) {
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
        writeEvents -level "Error" -msg "rebootVm.ps1 does not exist on remote server, check path."
    }
    # TODO: getReturn codes and return to main function
}


if ($args.Length -eq 0) {
    Write-Host "ERROR : Missing arguments ..."
    Write-Host "Please provide a virtual-machine name.`n"
    showHelpMenu
    exit 255

} elseif ($args.Length -eq 1) {
    writeEvents -level "Information" -msg "Starting to main operation..."

    if (($args[0] -eq "--help") -or ($args[0] -eq "-h")) {
        showHelpMenu
        exit 255
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
                    -msg "Failed to kick rebootVm.ps1 both on primary/secondary."
                exit 1

            }
        }

        writeEvents -level "Information" `
            -msg "parentScript completed its task successfully, exit the program."
        exit 0

    } else {
        writeEvents -level "Error" `
            -msg "testConnection failed both of child servers, check the connectivity."
        exit 128

    }

} else {
    Write-Host "ERROR : Too many arguments..."
    Write-Host "Restarting multiple virutal-machines at once is not supported, provide just one.`n"
    showHelpMenu
    exit 255
}
