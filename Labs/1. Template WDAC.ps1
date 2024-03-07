#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'WDACTemplate'
$AdminUser       = 'wsadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'WDAC01'

# Get-LabAvailableOperatingSystem will list all available OSes to you
$OperatingSystem = 'Windows 11 Enterprise Evaluation'

# WDAC Options
[ValidateSet("Allow", "Deny")]
[string]$WDACAction = "Allow"
[bool]$WDACDCS = $True # True, False

#--------------------------------------------------------------------------------------------------------------------
# CUSTOMROLE INSTLLATION
$ALCustomRolesFilePath = $labSources + '\CustomRoles'

# Copy the subdirectories of CustomRoles to the lab sources
Copy-Item -Path "C:\AutomatedBadLab\CustomRoles\*" -Destination $ALCustomRolesFilePath -Recurse -ErrorAction SilentlyContinue

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# Create a domain admin account to handle Windows machine creation / Active Directory configration. 
Set-LabInstallationCredential -Username $AdminUser -Password $AdminPass

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
# NETWORKING - https://automatedlab.org/en/latest/Wiki/Basic/networksandaddresses/
# Give Workstation Internet access via NAT switch
$VSwitch = Get-VMSwitch | Where-Object SwitchType -eq 'External'
Add-LabVirtualNetworkDefinition -Name $VSwitch.Name -HyperVProperties @{
    SwitchType = $VSwitch.SwitchType
    AdapterName = $VSwitch.NetAdapterInterfaceDescription
}

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/

# Install Windows Defender Application Control Custom Role
$WDACRole = Get-LabPostInstallationActivity -CustomRole WindowsDefenderApplicationControl -Properties @{
    Action = $WDACAction
    DCS = $WDACDCS
}

Add-LabMachineDefinition -Name $MachineName -Network $VSwitch.Name -PostInstallationActivity $WDACRole

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary -Detailed