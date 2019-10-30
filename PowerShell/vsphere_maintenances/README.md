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
