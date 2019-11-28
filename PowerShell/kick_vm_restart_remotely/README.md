# Kick VM Restart Remotely

- Using PowerShell Remoting Protocol (PSRP), Managing VM power status

***

## Environment

The Scripts in repository would be only tested under the environments below  
Please check your PowerShell/PowerCLI versions with `$PSVersionTable` and `Get-PowerCLIVersion` command let  

- Server on `parentScript.ps1` allocated
  - OS : Windows Server 2012R2 Standard
  - PowerShell : 4.0

- Servers on `childScript.ps1` and `cp-childScript.ps1` allocated
  - OS : Windows Server 2016 Standard
  - PowerShell : 5.1
  - PowerCLI : 11.3.0

***

## Pre-requirements

There are some pre-requirements for running these scripts  

- On Child Servers child scripts would be allocated
  - Create credential files for connecting vCenter Server where the target virtual machine exists.
    - Password file should be created under the project root path
    - Encrypted password would be stored in the file with functionality of PowerShell SecureString.
  - Note that the name of file encrypted password would be stored would be provided by the user whatever you like.
  - Also, the password file would be decrypted only by the user who would have encrypt.
    - So, if you have multiple remote servers on the system, you have to create the secret on each server.

- Creating encrypted password file for vCenter Server

```PowerShell
$username = "administrator@vsphere.local"
$creds = Get-Credential
#-> As pop-up shows, enter the credentials manually
$creds.Password | ConvertFrom-SecureString | Set-Content "vcenter.secret"
#-> Save as PowerShell SecureString objects

# Get password with secure from encrypted file
$password = Get-Content "vcenter.secret" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential $username, $password

# Checking with PS Object
Connect-VIServer -Server vcsa01.nfvlab.local -Credentials $credential
```


- Creating encrypted password file for ESXi Hosts
  - The CP scripts of `rebootVm.ps1` would connect to ESXi Hosts directly with PowerCLI.
  - So, it requires to create files for them apart from for vCenter Server's above.

``PowerShell
$username = "root"
$creds = Get-Credential
$creds.Password | ConvertFrom-SecureString | Set-Content "esxi.secret"
$password = Get-Content "esxi.secret" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential $username, $password
Connect-VIServer -Server vcsa01.nfvlab.local -Credentials $credential
```


