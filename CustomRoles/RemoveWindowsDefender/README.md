# Remove Windows Defender
## Defining the role
``` PowerShell
$RemoveDefenderRole = Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender

Add-LabMachineDefinition -Name WS01 -PostInstallationActivity $RemoveDefenderRole
```

## Deployment Details
The custom role does the following tasks
- Creates AV exception on the remote machine
- Downloads the Windows Defender Remover repo 
- Executes the bat file to nuke all Windows Security components:
    - Windows Defender
    - Windows SmartScreen
    - Windows Security Application
    - Tamper Protection

## Requirements
- Internet connected machine

## References
- https://github.com/ionuttbara/windows-defender-remover
