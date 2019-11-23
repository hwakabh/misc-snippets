# Preset command-line arguments
Param(
    [parameter(mandatory=$true)][String]$configFilePath,        # Path of configruration file
    [parameter(mandatory=$true)][String[]]$targetClusters,      # Names of cluster vm allocated
    [parameter(mandatory=$true)][String]$vmFilePath             # Path of file listing VM(s) to start
)

# Testing configuration file path
if ((Test-Path -Path $configFilePath) -eq $false) {
    Write-Host "Provided configuration file does not exist, please check the path."
    exit 128
}
if ((Test-Path -Path $vmFilePath) -eq $false) {
    Write-Host "Provided VM-List file does not exist, please check the path."
    exit 128
}

$configFile = Convert-Path -Path $configFilePath
$vmFile = Convert-Path -Path $vmFilePath
Write-Host ">>> Script started, read configuration ..."
Write-Host "Conf File Path :`t $configFile"
Write-Host ""

$lines = Get-Content $configFile
foreach ($line in $lines) {
    if($line -match "^$"){ continue }
    if($line -match "^#"){ continue }
    if($line -match "^\s*;"){ continue }

    $key, $value = $line -split ' = ',2 -replace "`"",''
    Invoke-Expression "`$$key='$value'"
}
# Read the target VM(s) to start as String array
$vmList = Get-Content $vmFile

Write-Host ">>> Reading parameters :"
Write-Host "vCenter :`t`t`t $vCenter"
Write-Host "username :`t`t`t $username"
Write-Host "Password File :`t`t`t $passwordFilename"
Write-Host "Operation Interval(Sec) :`t $waitIntervalSec"
Write-Host ""

# Set input path
$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$passwordFilePath = Join-Path -Path $scriptRoot -ChildPath $passwordFilename
Write-Host ">>> Determine path parameters"
Write-Host "RootPath :`t`t $scriptRoot"
Write-Host "PasswordFilePath :`t $passwordFilePath"
Write-Host ""

# Read password from file and make credentials
$password = Get-Content $passwordFilePath | ConvertTo-SecureString
$credential = New-Object -TypeName System.Management.Automation.PsCredential `
    -ArgumentList $username, $password
Write-Host ">>> Reading SecureString done"
Write-Host ""


# Establish connection to vCenter Server
$ErrorActionPreference = "stop"
try {
    Write-Host ">>> Connecting to vCenter Server ..."
    Connect-VIServer -Server $vCenter -Credential $credential
} catch {
    Write-Host "Failed to connect vCenter Server [ $vCenter ] ..."
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit 1
}
Write-Host ""


$ErrorActionPreference = "continue"
foreach ($cluster in $targetClusters) {
    $vmOnCluster = Get-Cluster -Name $cluster |Get-VM |Where-Object {$_.PowerState -eq "PoweredOff"}
    Write-Host ">>> Powering off VM(s) on Cluster [ $cluster ] ..."
    foreach ($vm in $vmList) {
        if ($vm -in $vmOnCluster.Name) {
            Write-Host ">>> Starting VM [ $($vm) ] ..."
            try {
                Start-VM -VM $vm
            } catch {
                Write-Host "Failed to power on VM [ $vm ] ..."
            }
            Write-Host ""
            Start-Sleep -Seconds $waitIntervalSec
        } else {
            Write-Host ">>> VM [ $vm ] is not on Cluster [ $cluster ] or already powered on, nothing to do for this VM ..."
            Write-Host ""
        }
    }
}

Write-Host ">>> Script done, disconnecting the server ..."
Disconnect-VIServer -Server $vCenter -Confirm:$false
exit 0
