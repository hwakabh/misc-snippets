# Pre-Requirements
$targetClusters = $args
$scriptRoot = "C:\Users\Administrator\Documents\misc-snippets\PowerShell\vsphere_maintenances"

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

foreach ($cluster in $targetClusters) {
    $esxihosts = Get-Cluster -Name $cluster |Get-VMHost
    foreach ($h in $esxihosts) {
        $profileName = "$($h.Name)_$(Get-Date -Format "yyyyMMdd_HHmmss")"
        Write-Host "Creating HostProfile of [ $($h.Name) ] with displayed name [ $profileName ]"
        New-VMHostProfile -Name $profileName -ReferenceHost $h
    }
}

exit 0
