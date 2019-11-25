# Preset command-line argument
Param(
    # [parameter(mandatory=$true)][String]$configFilePath,    # Path of configruration file
    # [parameter(mandatory=$true)][String]$downloadPath       # Local Path of downloading vc-support
    [parameter(mandatory=$true)][String[]]$targetMgrs,      # Target NSX-T Manager's IP/FQDN to retrieve support-bundle
    [parameter(mandatory=$true)][String[]]$targetEdgeNodes  # Target NSX-T Edge Nodes IP/FQDN to retrieve support-bundle
)


# TODO: Check user requirements to pass configFilePath as command-line arguments or not
$lines = Get-Content ".\credentials.txt"
foreach ($line in $lines) {
    if($line -match "^$"){ continue }
    if($line -match "^#"){ continue }
    if($line -match "^\s*;"){ continue }

    $key, $value = $line -split ' = ',2 -replace "`"",''
    Invoke-Expression "`$$key='$value'"
}
Write-Host ">>> Reading parameters :"
Write-Host "NSX-T Username :`t $username"
Write-Host "NSX-T Password File :`t $nsxPasswordFilename"
Write-Host ""

# Set input path
$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$passwordFilePath = Join-Path -Path $scriptRoot -ChildPath $nsxPasswordFilename
# $downloadPath = $scriptRoot
$downloadPath = "C:\vmware"
Write-Host ">>> Determine path parameters"
Write-Host "RootPath :`t`t $scriptRoot"
# Write-Host "Download Path :`t`t $downloadPath"
Write-Host "PasswordFilePath :`t $passwordFilePath"
Write-Host ""

# Read password from file and make credentials
$PasswordContent = Get-Content $passwordFilePath | ConvertTo-SecureString
$nsxPassword =  [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordContent)
$nsxRawPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($nsxPassword)
Write-Host ">>> Reading SecureString done"
Write-Host ""


# Pre-configuration for Invoke-WebRequest with ignoring TLS and with BASIC Authentication
$basicAuth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($nsxUsername + ":" + $nsxRawPassword))
$header = @{
    "Authorization" = "Basic $basicAuth";
    "Content-Type" = "application/json";
    "Accept" = "application/json";
}
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Main functions
# -- NSX-T Manager(s)
foreach ($mgr in $targetMgrs) {
    Write-Host ">>> Start to download NSX-T Manager [ $mgr ] support-bundles, it might take some time ..."

    Write-Host ">>> HTTP GET [ $mgr ]  UUID to POST ..."
    $ErrorActionPreference = "continue"
    try {
        $uri = "https://" + $mgr + "/api/v1/cluster/nodes"
        # TODO: Check if multiple NSX-T Manager configured
        Invoke-RestMethod -Uri $uri -Method Get -Headers $header |Select-Object -Property results |Set-Variable -Name mgrRes
    } catch {
        Write-Host "Failed to HTTP GET from NSX-T Manager [ $mgr ] ..."
        Write-Host ""
    }

    $mgrUuid = $mgrRes[0].results.external_id[0].trim()
    Write-Host "Target NSX-T Manager UUID : $mgrUuid"
    Write-Host ""

    Write-Host ">>> HTTP POST to [ $mgr ] for downloading bundles ..."
    try {
        $postUri = "https://" + $mgr + "/api/v1/administration/support-bundles?action=collect"
        $reqBody = "{`"nodes`": [`"$($mgrUuid)`"]}"
        # TODO: Check user requirements of timeoutsec
        Invoke-RestMethod -Uri $postUri -Method Post -Headers $header -Body $reqBody -TimeoutSec $timeoutSec -OutFile $downloadPath
    } catch {
        Write-Host "Failed to HTTP POST to NSX-T Manager [ $mgr ] Policy API ..."
    }
    Write-Host ""
}

# -- NSX-T Edge(s)
foreach ($edge in $targetEdgeNodes) {
    Write-Host ">>> Start to download NSX-T Edge [ $edge ] support-bundles, it might take some time ..."

    Write-Host ">>> HTTP GET [ $edge ]  UUID to POST ..."
    $ErrorActionPreference = "continue"
    try {
        $uri = "https://" + $mgr + "/api/v1/transport-nodes?node_types=EdgeNode"
        Invoke-RestMethod -Uri $uri -Method Get -Headers $header |Select-Object -Property results |Set-Variable -Name edgeRes
    } catch {
        Write-Host "Failed to HTTP GET responses from NSX-T [ $mgr ] Policy API ..."
    }

    # If multiplue edge configured, find olnly matched with value of $edge
    $edgeUuid = $edgeRes.results |Where-Object {$_.display_name -eq $edge} |Select-Object -Property id
    Write-Host "Target Edge TransportNode UUID : $edgeUuid"
    Write-Host ""

    Write-Host ">>> HTTP POST to [ $mgr ] for downloading edge [ $($edgeUuid.Id) ] bundles ..."
    try {
        $postUri = "https://" + $mgr + "/api/v1/administration/support-bundles?action=collect"
        $reqBody = "{`"nodes`": [`"$($edgeUuid.Id)`"]}"
        # TODO: Check user requirements of timeoutsec
        Invoke-RestMethod -Uri $postUri -Method Post -Headers $header -Body $reqBody -TimeoutSec $timeoutSec -OutFile $downloadPath
    } catch {
        Write-Host "Failed to HTTP POST to NSX-T [ $mgr ] Policy API, the Edge log-bundle would not be downloaded ..."
    }
    Write-Host ""
}

Write-Host ">>> Script done, exit the programs ..."
exit 0