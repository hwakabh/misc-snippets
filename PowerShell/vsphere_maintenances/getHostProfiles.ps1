# Preset command-line arguments
Param(
    [parameter(mandatory=$true)][String[]]$targetClusters,       # Names of target clusters to gather hostProfiles
    [parameter(mandatory=$true)][String]$downloadPath   # Local Path of downloading hostprofiles
)

# Pre-Requirements
$scriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent

# Credentials
$vCenter = "vcsa02.nfvlab.local"
$username = "administrator@vsphere.local"
$passwordFilePath = Join-Path $scriptRoot "password.dat"
$password = Get-Content $passwordFilePath | ConvertTo-SecureString
$credential = New-Object -TypeName System.Management.Automation.PsCredential `
    -ArgumentList $username, $password


# Main functions
$ErrorActionPreference = "stop"
try {
    Connect-VIServer -Server $vCenter -Credential $credential
} catch {
    Write-Host "Failed to connect vCenter Server [ $vCenter ]..."
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit 1
}

$ErrorActionPreference = "continue"
foreach ($cluster in $targetClusters) {
    $esxihosts = Get-Cluster -Name $cluster |Get-VMHost
    foreach ($h in $esxihosts) {
        $profileName = "$($h.Name)_$(Get-Date -Format "yyyyMMdd_HHmmss")"
        Write-Host "Creating HostProfile of [ $($h.Name) ] with displayed name [ $profileName ]"
        try {
            New-VMHostProfile -Name $profileName -ReferenceHost $h
        } catch {
            Write-Host "Failed to create HostProfile [ $profileName ] on $($h.Name) ..."
        }
    }
}

exit 0
