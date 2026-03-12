#--------------------------------------------------------------------------------------------------------------------
# CHANGEME - Global parameters
$LabName        = 'ActiveDirectoryTemplate'

# CHANGEME - Active Directory parameters
$DomainUser     = 'domainadmin'
$DomainPass     = 'complexpassword'
$Domain         = 'domain.tld'

# Path to our custom provisioning scripts
$CustomScripts  = 'C:\AutomatedBadLab\PostInstallationActivities'

#--------------------------------------------------------------------------------------------------------------------
# CUSTOMROLE INSTALLATION
$ABLCustomRolesFilePath = Join-Path $PSScriptRoot "..\CustomRoles"

# Copy the subdirectories of CustomRoles to the lab sources
Copy-Item -Path $ABLCustomRolesFilePath -Destination $labSources -Force -Recurse

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# Use NetNat to provide Internet access within an isolated network
Add-LabVirtualNetworkDefinition -Name $LabName -UseNat

# For any roles requiring ISOs, make AL aware of the location
Add-LabIsoImageDefinition -Name Office2016 -Path "$labSources\ISOs\Office 2016 Professional.iso"

# Create a domain admin account to handle Windows machine creation / Active Directory configration.
Set-LabInstallationCredential -Username $DomainUser -Password $DomainPass
Add-LabDomainDefinition -Name $Domain -AdminUser $DomainUser -AdminPassword $DomainPass

#--------------------------------------------------------------------------------------------------------------------
# DEFAULT MACHINE PARAMETERS
# Giving DomainName will automatically make all machines join the domain
# These can be overwritten as seen for WS01 - Windows 10 is wanted rather than Server 2019
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $LabName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:DomainName'       = $Domain
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = 'Windows Server 2025 Standard Evaluation (Desktop Experience)'
}

#--------------------------------------------------------------------------------------------------------------------
# POST INSTALLATION ACTIVITIES - https://automatedlab.org/en/latest/Wiki/Basic/invokelabcommand/
# AL comes with a script to create a couple of test users to the domain. AutomatedBadLab can be used for more complex labs
$ADPrep = Get-LabPostInstallationActivity -ScriptFileName 'PrepareRootDomain.ps1' -DependencyFolder $CustomScripts\PrepareRootDomain

#--------------------------------------------------------------------------------------------------------------------
# ROLES - https://automatedlab.org/en/latest/Wiki/Roles/roles/
# Either comma separated in the Add-LabMachineDefinition or defined as an array with specific parameters
$DCRole = Get-LabMachineRoleDefinition -Role RootDC @{
    SiteName = 'London'
    SiteSubnet = $Subnet
    IsReadOnly = 'False'
}

# Swapping RootDC for $Roles in DC01 definition would create the DC configured as above + install Office using the ISO provided
$Roles = @()
$Roles += $DCRole
$Roles += Office2016

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/
# Create the machine definition with its custom name, networking, Roles and Post-install activities
Add-LabMachineDefinition -Name DC01 -Roles RootDC -PostInstallationActivity $ADPrep

# For the workstation, use Get-LabAvailableOperatingSystem to get correct OS name
$WS1PostInstallJobs = @() # Will execute in order
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole UpdateWindows

Add-LabMachineDefinition -Name WS01 -OperatingSystem 'Windows 10 Enterprise Evaluation' -PostInstallationActivity $WS1PostInstallJobs

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

#--------------------------------------------------------------------------------------------------------------------
# INSTALLING SOFTWARE / FEATURES - https://automatedlab.org/en/latest/Wiki/Basic/installsoftware/
# Install software on all Lab VMs - Use SilentHQ / Google to find correct flags
Install-LabSoftwarePackage -ComputerName (Get-LabVM) -Path $labSources\SoftwarePackages\Git.exe -CommandLine '/VERYSILENT /NORESTART'

# Install RSAT just on workstation
Install-LabWindowsFeature -FeatureName RSAT -ComputerName WS01 -IncludeAllSubFeature

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary
