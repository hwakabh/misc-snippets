# Pre-Requirements
$targetClusters = $args
$scriptRoot = "C:\Users\Administrator\Documents\misc-snippets\PowerShell\vsphere_maintenances"

# Credentials
$vCenter = "vcsa02.nfvlab.local"
$username = "administrator@vsphere.local"
$password = Get-Content $passwordFilePath | ConvertTo-SecureString
$passwordFilePath = Join-Path $scriptRoot "password.dat"
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

foreach ($cluster in $targetClsuters) {
    # Retrieve Cluster name(s) as command line argument(s),
    # and unset ESXi host(s) in the cluster to maintenance mode.
    Get-Cluster -Name $cluster |Get-VMHost |Where-Object {$_.ConnectionState -eq "Maintenance"} |Set-VMHost -State "Connected"
}

exit 0
