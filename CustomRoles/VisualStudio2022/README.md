# Visual Studio Community 2022 Install
## Defining the role
``` PowerShell
$VS2022Role = Get-LabPostInstallationActivity -CustomRole VisualStudio2022

Add-LabMachineDefinition -Name WS01 -PostInstallationActivity $VS2022Role
```

## Deployment Details
The custom role does the following tasks
- Installs Visual Studio Community 2022

## Requirements
- Internet connected machine
