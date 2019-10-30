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
try {
    Connect-VIServer -Server $vCenter -Credential $credential
} catch {
    Write-Host "Failed to connect vCenter Server [ $vCenter ]..."
    Disconnect-VIServer -Server $vCenter
    exit 1
}

foreach ($cluster in $targetClsuters) {
    $esxihosts = Get-Cluster -Name $cluster
    foreach ($h in $esxihosts) {
        $profileName = "$h_$(Get-Date -Format "yyyyMMdd_HHmmss")"
        New-VMHostProfile -Name $profileName -ReferenceHost $h
    }
}

exit 0
