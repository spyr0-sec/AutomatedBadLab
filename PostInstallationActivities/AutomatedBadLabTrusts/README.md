# AutomatedBadLab Trusts
This needs to be executed as a PostInstallationActivity once all Domain Controllers are misconfigured.

## Defining the role
``` PowerShell
$ABLPostInstallActivitiesFilePath  = Join-Path $PSScriptRoot "..\PostInstallationActivities"

foreach ($DC in $DCDictionary.GetEnumerator()) {
    Invoke-LabCommand -ComputerName $DC.Name -ActivityName CreateForeignMemberships -FileName Add-ForeignMemberships.ps1 `
    -DependencyFolderPath $ABLPostInstallActivitiesFilePath\AutomatedBadLabTrusts
}
```

## Deployment Details
The script does the following tasks
- Finds all DomainLocal Security Groups on the local domain
- Finds all users with weak passwords on trusted domains
- Randomly adds foreign weak users as members to local groups
- Randomly adds foreign groups as members to local groups
