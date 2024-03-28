# Remove Microsoft Edge First Run Experience
## Defining the role
``` PowerShell
$NoFirstRunRole = Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience

Add-LabMachineDefinition -Name WS01 -PostInstallationActivity $NoFirstRunRole
```

## Deployment Details
The custom role does the following tasks
- Adds registry keys to stop the Microsoft Edge First Run Experience

## Requirements
- Internet connected machine

## References
- https://twitter.com/awakecoding/status/1750736577746084162
