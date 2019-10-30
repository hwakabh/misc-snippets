# Pre-Requirements
$targetClusters = $args
$scriptRoot = "C:\Users\Administrator\Documents\misc-snippets\PowerShell\vsphere_maintenances"

# Credentials
$vCenter = "vcsa02.nfvlab.local"
$username = "administrator@vsphere.local"
$password = Get-Content $passwordFilePath | ConvertTo-SecureString
$credential = New-Object -TypeName System.Management.Automation.PsCredential `
    -ArgumentList $username, $password


# Main functions
try {
    Connect-VIServer -Server $vCenter -Credentials $creds
} catch {
    Write-Host "Failed to connect vCenter Server [ $vCenter ]..."
    Disconnect-VIServer -Server $vCenter
    exit 1
}

# Collecting vc-support of vCenter
try {
    Get-Log -Bundle -Server $vCenter -DestinationPath ./
} catch {
    Write-Host "Failed to get vc-support [ $vCenter ]..."
    exit 1
}

# Collecting vm-support of each ESXi host
foreach ($cluster in $targetClsuters) {
    Get-Cluster -Name $cluster |Get-VMHost |Get-Log -Bundle -DestinationPath ./
}

exit 0
