#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'WDACTemplate'
$AdminUser       = 'wsadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'WDAC01'

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
    'Add-LabMachineDefinition:OperatingSystem'  = 'Windows 11 Enterprise Evaluation'
}

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/
$PostInstallJobs = @() # Will execute in order
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole WindowsDefenderApplicationControl -Properties @{
    Action = $WDACAction
    DCS = $WDACDCS
}
$PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience

Add-LabMachineDefinition -Name $MachineName -PostInstallationActivity $PostInstallJobs

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary
