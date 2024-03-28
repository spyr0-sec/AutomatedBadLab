# Labs
These scripts are provided to assist getting labs up and running as easily as possible

## Template Structure
For all provided templates, the user only needs to change the parameters in the first section which are clearly marked:
``` PowerShell
#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'StandaloneTemplate'
$AdminUser       = 'wsadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'WS01'
$Subnet          = '10.10.X.0/24'

# Get-LabAvailableOperatingSystem will list all available OSes to you
$OperatingSystem = 'Windows 10 Enterprise Evaluation'

#--------------------------------------------------------------------------------------------------------------------
```

The rest of the template follows a similar structure which hopefully should make it easy for users to build their own labs:
- Pull in any local Custom Role changes
- Create the lab definition
- Create local / domain user accounts
- Configure networking
- Provide default machine parameters
- Create each machine definition
    - Add CustomRoles
    - Add NetworkAdapters
- Install lab
- Execute post-install scripts
- Display deployment summary

## Checkpoints
As this is pure Powershell, this should (hopefully) provide consistent and repeatable environments. AutomatedLab features [checkpoint](https://automatedlab.org/en/latest/AutomatedLab/en-us/Checkpoint-LabVM/) which is recommended to revert labs rather than rebuilding.

``` PowerShell
Checkpoint-LabVM -ComputerName DC01 -SnapshotName "$(Get-Date) - Build Complete"
```

## Build Times
These rough timings are assuming base images have already been created for the selected operating system

- Single Machine
    - Client OS (~10 minutes)
    - Server OS (<10 minutes)
- Router 
    - Windows Server with DHCP Role (~20 minutes)
- Active Directory
    - Domain Controller + Certificate Authority + Workstation (~60 minutes)
    - AutomatedBadLab AD / ADCS / Trust Provisioning Roles (+20 minutes)
- DevBox 
    - Client OS + Visual Studio & VS Code Installation Roles (~30 minutes)
- Windows Updates Role
    - Dependant on how many, adds 30+ minutes per machine
