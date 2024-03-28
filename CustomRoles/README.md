# Custom Roles
Each custom role has its own README to provide more information on what it does.

## Role Structure
The [AutomatedLab Custom Roles README](https://automatedlab.org/en/latest/Wiki/Advanced/customroles/) provides an overview, TL;DR:
- The folder and script have to be the name of your Custom Role
    - HostStart.ps1 executes on your local HyperV machine first
    - "ROLENAME".ps1 executes on the remote lab machine
    - HostEnd.ps1 executes on your local HyperV machine last

## Known Issues
Custom Roles such as `RemoveFirstRunExperience` are very simple PowerShell scripts which gets executed on the remote machine. The AutomatedLab.Common module is expecting these scripts to contain parameters, you can patch the `Sync-Parameter` function to remove the non-breaking errors by adding the following code to `AutomatedLab.Common.psm1:1276`

``` PowerShell
    If ($null -eq $commandParameterKeys)
    {
        $commandParameterKeys = @()
    }

    If ($null -eq $parameterKeys)
    {
        $parameterKeys = @()
    }
```

Then re-import the Automated modules

``` PowerShell
Get-Module AutomatedLab* | Remove-Module
Import-Module AutomatedLab -Force
```

## README Format
```
# <TITLE>
Optional Summary

## Defining the role
\``` PowerShell
<Get-LabPostInstallationActivity>
<Add-LabMachineDefinition>
\```

## Deployment Details
The custom role does the following tasks
- Bullet Point
- List of what the
- Role does

## Requirements
- List any pre-reqs
- Internet Access / ISO file
- etc.

## References
- Helpful URLs
- Optional Section
```
