#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'StandaloneTemplate'
$AdminUser       = 'wsadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'WS01'

# Get-LabAvailableOperatingSystem will list all available OSes to you
$OperatingSystem = 'Windows 11 Enterprise Evaluation'

#--------------------------------------------------------------------------------------------------------------------
# CUSTOMROLE INSTALLATION
$ABLCustomRolesFilePath = Join-Path $PSScriptRoot "..\CustomRoles"

# Copy the subdirectories of CustomRoles to the lab sources
Copy-Item -Path $ABLCustomRolesFilePath -Destination $labSources -Force -Recurse

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# Retrieve the name of the external network switch
. Join-Path -Path $PSScriptRoot -ChildPath '..\Functions\Get-ExternalNetworkSwitch.ps1'
$ExternalNetwork = Get-ExternalNetworkSwitch
Add-LabVirtualNetworkDefinition -Name $ExternalNetwork.Name -HyperVProperties @{ SwitchType = $ExternalNetwork.SwitchType ; AdapterName = $ExternalNetwork.NetAdapterInterfaceDescription }

# Create a local admin account
Set-LabInstallationCredential -Username $AdminUser -Password $AdminPass

#--------------------------------------------------------------------------------------------------------------------
# DEFAULT MACHINE PARAMETERS
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $ExternalNetwork.Name
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = $OperatingSystem
}

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/
$PostInstallJobs = @() # Will execute in order
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole UpdateWindows

Add-LabMachineDefinition -Name $MachineName -PostInstallationActivity $PostInstallJobs

# Install our lab, has flags for level of output
Install-Lab #-Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary
