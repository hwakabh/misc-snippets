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

$ErrorActionPreference = "continue"
foreach ($cluster in $targetClusters) {
    $esxihosts = Get-Cluster -Name $cluster |Get-VMHost
    foreach ($h in $esxihosts) {
        Write-Host "Starting all VMs on ESXi Host [ $($h.Name) ]..."
        $vms = Get-VMHost -VMHost $($h.Name) |Get-VM |Where-Object {$_.PowerState -eq "PoweredOff"}
        foreach ($v in $vms) {
            Write-Host "Starting VM [ $($v.Name) ]..."
            try {
                Start-VM -Name $($v.Name)
            } catch {
                Write-Host "Failed to start VM [ $($v.Name) ]..."
            }
        }
    }
}

exit 0
