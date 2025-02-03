#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'WDACTemplate'
$AdminUser       = 'wsadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'WDAC01'
$Subnet          = '10.10.X.0/24'

# Get-LabAvailableOperatingSystem will list all available OSes to you
$OperatingSystem = 'Windows 11 Enterprise Evaluation'

# WDAC Options
[ValidateSet("Allow", "Deny")]
[string]$WDACAction = "Allow"
[bool]$WDACDCS = $True

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
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole WindowsDefenderApplicationControl -Properties @{
    Action = $WDACAction
    DCS = $WDACDCS
}
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience

Add-LabMachineDefinition -Name $MachineName -NetworkAdapter $NICs -PostInstallationActivity $PostInstallJobs

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary