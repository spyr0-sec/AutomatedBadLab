# Microsoft Advanced Threat Analytics
## Defining the role
``` PowerShell
$ATARole = Get-LabPostInstallationActivity -CustomRole AdvancedThreatAnalytics -Properties @{
    ATAIsoFilePath = "C:\AutomatedLab\ISOs\mu_advanced_threat_analytics_ata_version_1.9_x64_dvd_11796945.iso"
}

Add-LabMachineDefinition -Name DC01 -PostInstallationActivity $ATARole
```

## Deployment Details
The custom role does the following tasks
- Mounts the provided ISO locally
- Extracts the setup.exe and uploads to remote computer
- Silently installs Microsoft ATA

## Requirements
- Microsoft ATA ISO file

## References
- https://docs.microsoft.com/en-us/advanced-threat-analytics/ata-silent-installation#ata-gateway-silent-installation