# Preset command-line arguments
Param(
    [parameter(mandatory=$true)][String[]]$targetHosts,        # Name of target ESXi host(s) to apply hostProfile
    [parameter(mandatory=$true)][String]$inputFilePath      # Local Path of hostprofile to apply
)

# Testing local Profile path
if ((Test-Path -Path $inputFilePath) -eq $false) {
    Write-Host "Provided local hostProfile does not exist, please check the path."
    exit 128
}

$configFilename = ".\credentials.txt"
Write-Host ">>> Script started, read configuration from [ $configFilename ]..."
Write-Host ""

$lines = Get-Content $configFilename
foreach ($line in $lines) {
    if($line -match "^$"){ continue }
    if($line -match "^\s*;"){ continue }

    $key, $value = $line -split ' = ',2 -replace "`"",''
    Invoke-Expression "`$$key='$value'"
}
Write-Host ">>> Reading parameters :"
Write-Host "vCenter :`t $vCenter"
Write-Host "username :`t $username"
Write-Host "Password File :`t $passwordFilename"
Write-Host ""

# Set input path
$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$passwordFilePath = Join-Path -Path $scriptRoot -ChildPath $passwordFilename
$profilePath = Convert-Path -Path $inputFilePath
$profileName = (Convert-Path -Path $inputFilePath).Split('\')[-1].Replace('.vpf', '')
# DEBUG: on OSX env, delimiter should be `/` while Windows is `\`
# $profileName = (Convert-Path -Path $inputFilePath).Split('/')[-1].Replace('.vpf', '')
Write-Host ">>> Determine path parameters"
Write-Host "RootPath :`t`t`t $scriptRoot"
Write-Host "PasswordFilePath :`t`t $passwordFilePath"
Write-Host "Profile Local FullPath :`t $profilePath"
Write-Host "ProfileName :`t`t`t $profileName"
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

# Upload & Apply hostProfile to ESXi Host(s)
$ErrorActionPreference = "continue"
foreach ($h in $targetHosts) {

    # Remove hostProfile if name conflicts
    Write-Host ">>> Checking hostProfile [ $profileName ] already exists on vCenter Server or not ..."
    $isAlreadyUploaded = Get-VMHostProfile -ReferenceHost $h |Where-Object {$_.Name -eq $profileName}
    if ($isAlreadyUploaded -ne $null) {
        Write-Host "Profile [ $profileName ] already imported to vCenter Server, removing before uploading new one ..."
        Get-VMHostProfile -ReferenceHost $h -Name $profileName |Remove-VMHostProfile -Confirm:$false
    } else {
        Write-Host "No name conflict occured, starting to import local profile ..."
    }

    Write-Host ">>> Uploading local profile [ $profileName ] to vCenter Server ..."
    Import-VMHostProfile -Name $profileName -ReferenceHost $h -FilePath $profilePath
    Write-Host ""

    Write-Host ">>> Attaching hostProfile to host, notice that not applying configurations in this step ..."
    try {
        Invoke-VMHostProfile -AssociateOnly -Entity $h -Profile $profileName -Confirm:$false
    } catch {
        Write-Host "Failed to attach profile [ $profileName ] to ESXi Host [ $h ]"
    }

    # TODO: Confirm user requirements for features of checking compliance
    #   Test-VMHostProfileCompliance -VMHost $h

    Write-Host ">>> Checking if ESXi Host is under maintenanceMode for apply configuration ..."
    $hostState = Get-VMHost -Name $h |Select-Object -Property ConnectionState
    if ($($hostState.ConnectionState) -ne "Maintenance") {
        Write-Host "Target ESXi Host [ $h ] is not under maintenaceMode, nothing to do for remediation ..."
        Write-Host ""

        Write-Host ">>> Removing hostProfile [ $profileName ] from vCenter Server ..."
        Get-VMHost -Name $h |Get-VMHostProfile -Name $profileName |Remove-VMHostProfile -Confirm:$false

    } else {
        Write-Host "Target ESXi Host [ $h ] requires maintenanceMode for remediation."
        Write-Host ""

        Write-Host ">>> Applying hostProfile [ $profileName ] to ESXi Host [ $h ] ..."
        try {
            Invoke-VMHostProfile -ApplyOnly -Entity $h -Profile $profileName -Confirm:$false
        } catch {
            Write-Host "Failed to apply configurations to ESXi [ $($h.Name) ]..."
        }

        Write-Host ">>> Removing hostProfile [ $profileName ] already applied to ESXi Host ..."
        Get-VMHost -Name $h |Get-VMHostProfile -Name $profileName |Remove-VMHostProfile -Confirm:$false
    }
}

Write-Host ">>> Script done, disconnecting the server ..."
Disconnect-VIServer -Server $vCenter -Confirm:$false
exit 0
