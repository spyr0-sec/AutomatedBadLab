#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'DevBoxTemplate'
$AdminUser       = 'devadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'DevBox'

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

# Create a local admin account
Set-LabInstallationCredential -Username $AdminUser -Password $AdminPass

#--------------------------------------------------------------------------------------------------------------------
# DEFAULT MACHINE PARAMETERS
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $LabName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = 'Windows 11 Enterprise Evaluation'
}

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/
$PostInstallJobs = @() # Will execute in order
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole VisualStudio2022
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole VisualStudioCode
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience

Add-LabMachineDefinition -Name $MachineName -PostInstallationActivity $PostInstallJobs

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary
