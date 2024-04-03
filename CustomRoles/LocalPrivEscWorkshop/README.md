# Windows Local Privilege Escalation Cookbook
## Defining the role
``` PowerShell
$PostInstallJobs = @() # Will execute in order
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole LocalPrivEscWorkshop -Properties @{
    LocalUsername = 'lowprivuser'
    LocalPassword = 'BetterS3cureP@ssw0rd'
}

Add-LabMachineDefinition -Name LPEWS01 -PostInstallationActivity $PostInstallJobs
```

## Deployment Details
The custom role does the following tasks
- Downloads latest LPE Cookook
- Reads each script (if applicable) into memory and executes
- Creates a defined local user account to use during the workshop

## Requirements
- Internet connected machine
- RemoveWindowsDefender Role (Optional but recommended)

## References
- https://github.com/nickvourd/Windows-Local-Privilege-Escalation-Cookbook
