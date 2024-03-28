# Windows Defender Application Control (WDAC)
## Defining the role
``` PowerShell
$WDACRole = Get-LabPostInstallationActivity -CustomRole WindowsDefenderApplicationControl -Properties @{
    Action = "Allow" # ["Allow", "Deny"]
    DCS    = $True   # [$True, $False]
}

Add-LabMachineDefinition -Name WDAC01 -PostInstallationActivity $WDACRole
```

## Deployment Details
The custom role does the following tasks
- Creates WDAC policy
- Deploys policy locally or via GPO if domain joined

## Requirements
- Internet connected machine
