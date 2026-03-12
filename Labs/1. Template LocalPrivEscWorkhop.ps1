#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'LocalPrivEscWorkshopTemplate'
$AdminUser       = 'wsadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'LPEWS01'

# Low priv user parameters - REMOVE OR CHANGE
$LocalUser       = 'lowprivuser'
$LocalPass       = 'BetterS3cureP@ssw0rd'

#--------------------------------------------------------------------------------------------------------------------
# CUSTOMROLE INSTALLATION
$ABLCustomRolesFilePath = Join-Path $PSScriptRoot "..\CustomRoles"

# Copy the subdirectories of CustomRoles to the lab sources
Copy-Item -Path $ABLCustomRolesFilePath -Destination $labSources -Force -Recurse

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# Create a local admin account
Set-LabInstallationCredential -Username $AdminUser -Password $AdminPass

# Use NetNat to provide Internet access within an isolated network
Add-LabVirtualNetworkDefinition -Name $LabName -UseNat

#--------------------------------------------------------------------------------------------------------------------
# DEFAULT MACHINE PARAMETERS
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $LabName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = 'Windows 10 Enterprise Evaluation'
}

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/
$PostInstallJobs = @() # Will execute in order
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole LocalPrivEscWorkshop -Properties @{
    LocalUsername = $LocalUser
    LocalPassword = $LocalPass
}

Add-LabMachineDefinition -Name $MachineName -PostInstallationActivity $PostInstallJobs

# Install our lab, has flags for level of output
Install-Lab #-Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary
