# Read configuration
$lines = Get-Content .\settings.txt
foreach ($line in $lines) {
    if($line -match "^$"){ continue }
    if($line -match "^\s*;"){ continue }

    $key, $value = $line -split ' = ',2 -replace "`"",''
    Invoke-Expression "`$$key='$value'"
}

$scriptName = $PSCommandPath.Split('\')[-1]
$scriptPath = Convert-Path .
$childFileName = "rebootVm.ps1"
$childDirPath = $scriptPath


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
        $msg = "Start to kick remote ps1 file [ $path ] on remote server [ $target ].`nNote that the virtual-machine [ $vmname ] would be restarted on hardware-level."

        Write-Host $msg
        writeEvents -level "Information" -msg $msg

        Write-Host "Running commad [ powershell.exe $path $vmname ] on $target ...`n"
        writeEvents -level "Information" -msg "Running command [ powershell.exe $path $vmname ] on $target ..."
        Write-Host "stdout.$childFileName >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        try {
            $stdout = Invoke-Command -ComputerName $target `
                -ScriptBlock { powershell.exe $args[0] $args[1]} `
                -ArgumentList $path, $vmname `
                -ErrorAction Continue
            foreach ($line in $stdout){
                Write-Host $line
            }
            Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        } catch {
            return 1
        }
        return 0

    } else {
        writeEvents -level "Error" -msg "rebootVm.ps1 does not exist on remote server, check path."
        return 1
    }
}


if ($args.Length -eq 0) {
    Write-Host "ERROR : Missing arguments ..."
    Write-Host "Please provide a virtual-machine name.`n"
    showHelpMenu
    exit 255

} elseif ($args.Length -eq 1) {
    if (($args[0] -eq "--help") -or ($args[0] -eq "-h")) {
        showHelpMenu
        exit 255
    }

    Write-Host ">>> Script [ $scriptName ] started, reading parameters."
    Write-Host ">>> Set Primary remote server [ $primaryChildIp ]"
    Write-Host ">>> Set Secondary remote server [ $secondaryChildIp ]"
    Write-Host ">>> Determined path of child script [ $childFileName ] with [ $childDirPath ]`n"

    Write-Host ">>> Strating to main operation ..."
    writeEvents -level "Information" -msg "Starting to main operation..."

    Write-Host ">>> Checking connectivities with testConnection() ..."
    if ((testConnection -target $primaryChildIp) -or (testConnection -target $secondaryChildIp)) {
        $filePath = Join-Path $childDirPath $childFileName
        $ErrorActionPreference = "stop"

        # Try initial call
        Write-Host ">>> Start operation on primary server ..."
        $ret_1 = callChildScript -target $primaryChildIp -path $filePath -vmname $args[0]

        if ($ret_1 -ne 0) {
            Write-Host ">>> Failed to call script on primary server.`n`n"

            # Retry if failed
            Write-Host ">>> Retrying the operations on secondary server ..."
            writeEvents -level "Warning" -msg "Failed to callChildScript() on primary server, continue on secondary one ..."
            $ret_2 = callChildScript -target $secondaryChildIp -path $filePath -vmname $args[0]
            if ($ret_2 -ne 0) {
                Write-Host ">>> Failed to callChildScript() on secondary server.`n"
                writeEvents -level "Error" -msg "Failed to kick rebootVm.ps1 both on primary/secondary."
                Write-Host "[ RESULT ]The program failed to call remote scripts both of remove server. Exit the program."
                exit 1
            }
        }

        Write-Host "[ RESULT ]parentScript completed its task successfully, exit the program."
        writeEvents -level "Information" -msg "parentScript completed its task successfully, exit the program."
        exit 0

    } else {
        writeEvents -level "Error" -msg "[ RESULT ]testConnection() failed both of child servers, check the connectivity."
        exit 128

    }

} else {
    Write-Host "ERROR : Too many arguments..."
    Write-Host "Restarting multiple virutal-machines at once is not supported, provide just one.`n"
    showHelpMenu
    exit 255
}
