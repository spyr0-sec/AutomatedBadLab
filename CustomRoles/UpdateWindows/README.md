# Update Windows
## Defining the role
``` PowerShell
$UpdateRole = Get-LabPostInstallationActivity -CustomRole UpdateWindows

Add-LabMachineDefinition -Name WS01 -PostInstallationActivity $UpdateRole
```

## Deployment Details
The custom role does the following tasks
- Installs pre-reqs to install PowerShell Gallery Modules
- Installs PSWindowsUpdate Module
- Creates a scheduled task to run the `Install-WindowsUpdate` cmdlet as SYSTEM

## Requirements
- Internet connected machine

## References
- https://github.com/mgajda83/PSWindowsUpdate