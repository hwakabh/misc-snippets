# Maintence Scripts for vSphere

- Some misc scripts for maintenance operations of vSphere environment.

## Pre-requirements

For the scripts to handle vSphere, there are some requirements to run these scripts.

- Create file for authentication
  - The scripts uses PowerShell `SecureString` objects for some security reaseons.
  - Instead of hard-codings of vSphere credentials, the user needs to create password files before runs scripts.

```PowerShell
$cred = Get-Credential
#-> As pop-up or prompt shows, enter the credentials of vSphere to maintain
$cred.Password | ConvertFrom-SecureString | Set-Content "<FILE_NAME_TO_STORE_SECURE_STRING>"

# Get encrypted-password from file
$username = "administrator@vsphere.local"
#-> Set username as entering pop-up
$password = Get-Content "<FILE_NAME_TO_STORE_SECURE_STRING>" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential $username, $password

# Connection Check
Connect-VIServer -Server "<VCENTER_FQDN>" -Credentials $credential
Disconnect-VIServer -Server "<VCENTER_FQDN>"
```

***

## Configuration files

- For every scripts, it requires the configuration file with command-line arguments.
  - All the configurations/parameters would be defined in this configuration file and user could modify this according to their environment.
- Within the file, commend-out with `#` would be supported for each description.

- `credentials.txt`

***

## Script Purpose & Descriptions

- The files within this repository would be used for specific senarios for vSphere opertionals
  - Managing ESXi Host Profiles for backup & restore
    - `getHostProfiles.ps1`
      - Collecting ESXi HostProfiles within the clusters, and download them to local computer where running this script.
        - Note that if already exist the profiles on local machinea with same names as target one, the local profiles would be overwritten.
      - Note that the existing HostProfiles related to ESXi Host configured on vCenter Server would be deleted and created new ones.
    - `applyHostProfiles.ps1`
      - Upload ESXi HostProfiles from local machine to remote vCenter Server, and applying to each ESXi Hosts.
      - Note that if the profiles had already existed on remote server with same name as target ones, the profiles would be deleted and uploaded new ones.
  - Managing VMs
    - `startAllVms.ps1` and `vmList.txt`
      - Powering on VMs provided on `vmList.txt` at the same time for maintenance recovery.
      - The script would be read the input file `vmList.txt`, and call the `StartVM` commandlet with the order described in the file.
  - Managing ESXi Hosts
    - `setHostMaintenanceMode.ps1`
    - `exitHostMaintenanceMode.ps1`
    - `shutdownHosts.ps1`
  - Managing Log-Bundles
    - `getEsxiLogBundles.ps1`
    - `getVcenterLogBundle.ps1`
    - `getNsxLogs.ps1`
