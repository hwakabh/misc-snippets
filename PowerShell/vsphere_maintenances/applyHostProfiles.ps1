# Preset command-line arguments
Param(
    [parameter(mandatory=$true)][String]$targetHost,        # Name of target ESXi host to apply hostProfile
    [parameter(mandatory=$true)][String]$inputFilePath      # Local Path of hostprofile to apply
)

# Set input path
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
        # Find hostProfile referenced by itself
        # TODO: If there are multiplue hostProfiles referenced by host, determine latest one
        $hostProfile = Get-VMHostProfile -ReferenceHost $h

        # Attaching hostProfile to host, not applying configurations in this step
        Invoke-VMHostProfile -AssociateOnly -Entity $h -Profile $hostProfile -Confirm:$false
        Write-Host "Attaching profile [ $($hostProfile.Name) ] to ESXi [ $($h.Name) ]..."

        # TODO: Confirm requirements for features of checking compliance
        # Test-VMHostProfileCompliance -VMHost $h

        # Check ESXi Host status since maintenaceMode would be required by profile remediation
        if ($($h.State) -eq "Maintenance") {
            Write-Host "Failed to apply configurations to ESXi [ $($h.Name) ] since it is not under maintenace mode..."
        } else {
            try {
                Invoke-VMHostProfile -Apply -Entity $h -Profile $hostProfile -Confirm:$false
            } catch {
                Write-Host "Failed to apply configurations to ESXi [ $($h.Name) ]..."
            }
            Write-Host "HostProfile [ $($hostProfile.Name) ] was successfully applied to ESXi [ $($h.Name) ]"
        }
    }
}

exit 0
