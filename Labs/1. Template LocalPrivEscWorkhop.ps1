#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'LocalPrivEscWorkshopTemplate'
$AdminUser       = 'wsadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'LPEWS01'
$Subnet          = '10.10.X.0/24'

# Low priv user parameters - REMOVE OR CHANGE
$LocalUser       = 'lowprivuser'
$LocalPass       = 'BetterS3cureP@ssw0rd'

# Get-LabAvailableOperatingSystem will list all available OSes to you
$OperatingSystem = 'Windows 10 Enterprise Evaluation'

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

#--------------------------------------------------------------------------------------------------------------------
# NETWORKING - https://automatedlab.org/en/latest/Wiki/Basic/networksandaddresses/
# For Internal networks, just need a name and subnet space. Internet Network is a static NAT network
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace $Subnet
Add-LabVirtualNetworkDefinition -Name "Internet" -AddressSpace 10.10.0.0/24

# Machines share a common Dual-homed NIC configuration
$NICs = @()
$NICs += New-LabNetworkAdapterDefinition -VirtualSwitch $LabName
$NICs += New-LabNetworkAdapterDefinition -VirtualSwitch 'Internet' -UseDhcp

#--------------------------------------------------------------------------------------------------------------------
# DEFAULT MACHINE PARAMETERS
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $labName
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
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole LocalPrivEscWorkshop -Properties @{
    LocalUsername = $LocalUser
    LocalPassword = $LocalPass
}

Add-LabMachineDefinition -Name $MachineName -NetworkAdapter $NICs -PostInstallationActivity $PostInstallJobs

# Install our lab, has flags for level of output
Install-Lab #-Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary
