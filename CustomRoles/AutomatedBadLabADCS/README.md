# AutomatedBadLab ADCS
## Defining the role
``` PowerShell
$BadADCSRole = Get-LabPostInstallationActivity -CustomRole AutomatedBadLabADCS

Add-LabMachineDefinition -Name CA1 -Role CaRoot -PostInstallationActivity $BadADCSRole
```

## Deployment Details
The custom role does the following tasks
- Uses `New-LabCATemplate` from AutomatedLab to create certificate Templates
- (Mis)configures these to make them vulnerable to ESC attacks
- (Mis)configures registry keys on the DC for other ESC attacks

## Requirements
- None
