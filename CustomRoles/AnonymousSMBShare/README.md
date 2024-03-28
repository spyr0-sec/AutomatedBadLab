# Create Anonymous SMB Share
## Defining the role
``` PowerShell
$SmbRole = Get-LabPostInstallationActivity -CustomRole AnonymousSMBShare -Properties @{
    SMBPath        = "Share"
    SMBName        = "C:\Share"
    SMBDescription = "Anonymous SMB Share"
}

Add-LabMachineDefinition -Name FILESERVER1 -PostInstallationActivity $SmbRole
```

## Deployment Details
The custom role does the following tasks
- Adds registry keys to allow Guest access to SMB shares
- Enables the Guest local user
- Creates the provided $SMBPath
- Provides Guest NTFS permissions to $SMBPath
- Exports $SMBPath as share

## Requirements
- None
