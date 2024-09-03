#--------------------------------------------------------------------------------------------------------------------
# CHANGEME - Global parameters
$LabName        = 'AutomatedBadLabTemplate'

# CHANGEME - Active Directory parameters
$DomainUser     = 'domainadmin'
$DomainPass     = 'complexpassword'
$Domain         = 'domain.tld' 

# CHANGEME - Certificate Authority parameters
$CAName         = 'AutomatedBadLabCA'

#--------------------------------------------------------------------------------------------------------------------
# CUSTOMROLE INSTALLATION
$ABLCustomRolesFilePath = Join-Path $PSScriptRoot "..\CustomRoles"

# Copy the subdirectories of CustomRoles to the lab sources
Copy-Item -Path $ABLCustomRolesFilePath -Destination $labSources -Force -Recurse

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# Create a domain admin account to handle Windows machine creation / Active Directory configration. 
# NOTE: Make sure these passwords are the same and needs to be complex
Add-LabDomainDefinition -Name $Domain -AdminUser $DomainUser -AdminPassword $DomainPass
Set-LabInstallationCredential -Username $DomainUser -Password $DomainPass

# Retrieve the name of the external network switch
. Join-Path -Path $PSScriptRoot -ChildPath '..\Functions\Get-ExternalNetworkSwitch.ps1'
$ExternalNetwork = Get-ExternalNetworkSwitch
Add-LabVirtualNetworkDefinition -Name $ExternalNetwork.Name -HyperVProperties @{ SwitchType = $ExternalNetwork.SwitchType ; AdapterName = $ExternalNetwork.NetAdapterInterfaceDescription }

#--------------------------------------------------------------------------------------------------------------------
# Defining default parameter values, as these ones are the same for all the machines. 
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $ExternalNetwork.Name
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:DomainName'       = $Domain 
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = 'Windows Server 2022 Standard Evaluation (Desktop Experience)'
}

#--------------------------------------------------------------------------------------------------------------------
# Domain Controller provisioning
$DC1PostInstallJobs = @() # Will execute in order
$DC1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole UpdateWindows
$DC1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole AutomatedBadLab

Add-LabMachineDefinition -Name BBDC01 -Roles RootDC -PostInstallationActivity $DC1PostInstallJobs

# Certificate Authority provisioning
$CARole = Get-LabMachineRoleDefinition -Role CaRoot @{
    CACommonName        = $CAName
    KeyLength           = '4096'
    ValidityPeriod      = 'Years'
    ValidityPeriodUnits = '20'
}

$CA1PostInstallJobs = @() # Will execute in order
$CA1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole AutomatedBadLabADCS

Add-LabMachineDefinition -Name BBCA01 -Roles $CARole -PostInstallationActivity $CA1PostInstallJobs

# Workstation provisioning
$WS1PostInstallJobs = @() # Will execute in order
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole UpdateWindows

# For the workstation, use Get-LabAvailableOperatingSystem to get correct OS name
Add-LabMachineDefinition -Name BBWS01 -PostInstallationActivity $WS1PostInstallJobs -OperatingSystem 'Windows 10 Enterprise Evaluation' 

# Install our lab, has flags for level of output
Install-Lab #-Verbose -Debug

<# Debugging - Remove all objects created by AutomatedBadLab
Invoke-LabCommand -ComputerName BBDC01 -ActivityName RemoveAutomatedBadLab -FileName Remove-AllBLADObjects -DependencyFolderPath $CustomScripts\AutomatedBadLab\AD_Delete_All

Write-ScreenInfo "Removing Insecure ADCS Templates" # Runs locally
. "$CustomScripts\AutomatedBadLab\ADCS_Delete_All\Remove-AllBLADCSObjects.ps1"
Remove-AllBLADCSObjects
#>

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary -Detailed
