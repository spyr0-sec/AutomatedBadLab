# Remove Windows Defender
## Defining the role
``` PowerShell
$RemoveDefenderRole = Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender

Add-LabMachineDefinition -Name WS01 -PostInstallationActivity $RemoveDefenderRole
```

## Deployment Details
The custom role does the following tasks
- Creates AV exception on the remote machine
- Uploads the .ps1 and .bat files 
- Creates a scheduled task to run the bat file as SYSTEM to nuke all Windows Security software:
    - Windows Defender
    - Windows SmartScreen
    - Windows Security Application
    - Tamper Protection

## Requirements
- None

## References
- https://github.com/ionuttbara/windows-defender-remover
