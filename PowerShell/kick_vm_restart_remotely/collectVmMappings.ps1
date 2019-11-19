# NOTE: this scripts pre-requires vcenter.secret file generated with Get-Credential cmdlet
$scriptPath = Split-Path $MyInvocation.MyCommand.Path -Parent
$passwordFilePath = Join-Path -Path $scriptPath -ChildPath "vcenter.secret"

$vCenter = "vcsa01.nfvlab.local"
$username = "administrator@vsphere.local"
$password = Get-Content $passwordFilePath | ConvertTo-SecureString
$credential = New-Object -TypeName System.Management.Automation.PsCredential `
    -ArgumentList $username, $password

$outFileName = "result.csv"

$ErrorActionPreference = "stop"
try {
    Connect-VIServer -Server $vCenter -Credential $credential |Out-Null
    Write-Output ">>> Successfully connected vCenter Server [ $vCenter ]"
} catch {
    Write-Output ">>> Failed to connect vCenter Server [ $vCenter ]. Exit the program."
    exit 128
}

# Collecting relations and export them to csv.
Write-Output ">>> Dumping relations with virtual-machines..."
&{foreach($dc in Get-Datacenter){
    foreach($cluster in Get-Cluster -Location $dc){
        foreach($esxi in Get-VMHost -Location $cluster){
            Get-VM -Location $esxi |
            Select @{N='Datacenter';E={$dc.Name}},
                @{N='Cluster';E={$cluster.Name}},
                @{N='VMhost';E={$esxi.Name}},Name
        }
    }
}} | Export-Csv $outFileName -NoTypeInformation -UseCulture
Write-Output ">>> Successfully exported to csv file [ $outFileName ].`n"
exit 0
