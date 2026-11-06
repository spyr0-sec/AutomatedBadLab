# Provision SCCM
This needs to be executed as a PostInstallationActivity once the Configuration Manager site is installed.

## Defining the role
``` PowerShell
$ABLPostInstallActivitiesFilePath  = Join-Path $PSScriptRoot "..\PostInstallationActivities"

$CMServer = Get-LabVM -Role ConfigurationManager

# The script runs long (the device imports + the user discovery) so run it as a job
# NOTE: -FilePath (NOT -FileName - the old-API name; 5.61's param = -FilePath)
$Job = Invoke-LabCommand -ComputerName $CMServer -ActivityName ProvisionSCCM -FilePath "$ABLPostInstallActivitiesFilePath\ProvisionSCCM\Provision-SCCM.ps1" `
-DependencyFolderPath $ABLPostInstallActivitiesFilePath\ProvisionSCCM -ArgumentList 'LD1', 20 -AsJob -PassThru

Wait-Job -Job $Job -Timeout 3600
```

## Deployment Details
The script does the following tasks
- Imports all AD computer accounts into the "All ABL Devices" device collection
- Enables the AD User Discovery and adds a random selection of 20 users to the "Selected Users" user collection
- Downloads and creates the Notepad++ and 7-Zip applications
- Distributes and deploys both applications to the "All ABL Devices" collection
