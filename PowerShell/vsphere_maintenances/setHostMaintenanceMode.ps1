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
    exit 1
}

foreach ($cluster in $targetClsuters) {
    # Retrieve Cluster name(s) as command line argument(s),
    # and set ESXi host(s) in the cluster to maintenance mode.
    Get-Cluster -Name $cluster
}

exit 0
