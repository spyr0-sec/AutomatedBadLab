# OffensivePipeline
Pipeline to download, build and obfuscate .NET Red Team tooling. Recommend to use in conjuction with RemoveWindowsDefender and AnonymousSMBShare roles.

## Defining the role
``` PowerShell
$PostInstallJobs = @() # Will execute in order
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole OffensivePipeline
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole AnonymousSMBShare -Properties @{
    SMBName ='Tools'
    SMBPath ='C:\OffensivePipeline\OfensivePipeline_v2.0.0\Output'
    SMBDescription ='Obfsucated Tools Share'
}

Add-LabMachineDefinition -Name TOOLSERVER1 -PostInstallationActivity $PostInstallJobs
```

## Deployment Details
The custom role does the following tasks
- Installs VS Build Tools
- Installs all versions of .NET Framework
- Installs OffensivePipeline and compiles all tools

## Requirements
- Internet connected machine
- Windows Server Operating System

## References
- https://github.com/Aetsu/OffensivePipeline
