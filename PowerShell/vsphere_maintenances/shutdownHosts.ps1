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
    $esxihosts = Get-Cluster -Name $cluster |Get-VMhost
    $ErrorActionPreference = "continue"
    foreach ($h in $esxihosts) {
        if ($esxihosts.ConnectionState -eq "Maintenance") {
            Write-Host "ESXi host [ $($h.Name) ] is not under MaintenanceMode, nothing to do for this host."
        } else {
            Write-Host "Shutting down ESXi host [ $($h.Name) ], this operation might take some minutes..."
            try {
                Stop-VMhost -VMhost $h -Confirm:$false
            } catch {
                Write-Host "Failed to shutdown ESXi host [ $($h.Name) ]..."
            }
        }
    }
}

exit 0
