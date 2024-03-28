# Windows Defender Application Guard
## Defining the role
``` PowerShell
$AppGuardRole = Get-LabPostInstallationActivity -CustomRole WindowsDefenderApplicationGuard

Add-LabMachineDefinition -Name WS01 -PostInstallationActivity $AppGuardRole
```

## Deployment Details
The custom role does the following tasks
- Installs WindowsDefenderApplicationGuard feature
- Removes hardware restrictions

## Requirements
- Internet connected machine
