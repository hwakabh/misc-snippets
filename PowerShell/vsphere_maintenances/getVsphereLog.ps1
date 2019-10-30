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

# Collecting vc-support of vCenter
try {
    Get-Log -Bundle -Server $vCenter -DestinationPath ./
} catch {
    Write-Host "Failed to get vc-support [ $vCenter ]..."
    Disconnect-VIServer -Server $vCenter -Confirm:$false
    exit 1
}

# Collecting vm-support of each ESXi host
foreach ($cluster in $targetClusters) {
    $esxihosts = Get-Cluster -Name $cluster |Get-VMHost
    foreach ($h in $esxihosts) {
        try {
            Get-Log -Bundle -VMHost $h -DestinationPath ./
        } catch {
            Write-Host "Failed to get vm-support of [ $h ]"
            Disconnect-VIServer -Server $vCenter -Confirm:$false
            exit 1
        }
    }
}

exit 0
