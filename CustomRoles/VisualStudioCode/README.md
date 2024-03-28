# Visual Studio Code Install
## Defining the role
``` PowerShell
$VSCodeRole = Get-LabPostInstallationActivity -CustomRole VisualStudioCode

Add-LabMachineDefinition -Name WS01 -PostInstallationActivity $VSCodeRole
```

## Deployment Details
The custom role does the following tasks
- Installs latest version of Visual Studio Code

## Requirements
- Internet connected machine
