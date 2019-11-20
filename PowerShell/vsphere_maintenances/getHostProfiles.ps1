# Preset command-line arguments
Param(
    [parameter(mandatory=$true)][String[]]$targetClusters,  # Names of target clusters to gather hostProfiles
    [parameter(mandatory=$true)][String]$downloadPath       # Local Path of downloading hostprofiles
)

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

# Create & Download new hostProfiles with every hosts in target cluster(s)
$ErrorActionPreference = "continue"

foreach ($cluster in $targetClusters) {
    Write-Host ">>> Getting ESXi Host(s) in cluster [ $cluster ] ..."
    $esxihosts = Get-Cluster -Name $cluster |Get-VMHost
    Write-Host ""

    foreach ($h in $esxihosts) {
        $profileName = "Profile-$($h.Name)-$(Get-Date -Format "yyyyMMdd")"

        # Remove hostProfile if name confiliction occured
        Write-Host ">>> Checking HostProfile already created or not with same name ..."
        $isProfileExist = Get-VMHostProfile -ReferenceHost $h |Where-Object {$_.Name -eq $profileName}
        if ($isProfileExist -ne $null) {
            Write-Host "HostProfile [ $profileName ] found on vCenter, deleting before createing new one ..."
            Get-VMHostProfile -ReferenceHost $h -Name $profileName |Remove-VMHostProfile -Confirm:$false
        } else {
            Write-Host "No name conflicts of hostProfile, starting create ..."
        }

        Write-Host ">>> Creating HostProfile of [ $($h.Name) ] with displayed name [ $profileName ]"
        try {
            New-VMHostProfile -Name $profileName -ReferenceHost $h
        } catch {
            Write-Host "Failed to create HostProfile [ $profileName ] on $($h.Name) ..."
        }
        Write-Host ""

        # Download hostProfile with host to local
        Write-Host ">>> Exporting HostProfile of ESXi Host to local ..."
        try {
            # If already downloaded profiles with same name, overwrite the files with -Force option
            Get-VMHostProfile -ReferenceHost $h -Name $profileName |Export-VMHostProfile -FilePath $downloadPath -Force:$true
        } catch {
            Write-Host "Failed to download HostProfile [ $profileName ] to local-path [ $downloadPath ] ..."
        }
        Write-Host ""

    }

}

Write-Host ">>> Script done, disconnecting the server ..."
Disconnect-VIServer -Server $vCenter -Confirm:$false
exit 0
