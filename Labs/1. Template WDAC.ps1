#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'WDACTemplate'
$Subnet          = '10.10.X.0/24'
$AdminUser       = 'wsadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'WDAC01'

# Get-LabAvailableOperatingSystem will list all available OSes to you
$OperatingSystem = 'Windows 11 Enterprise Evaluation'

# WDAC Options
[ValidateSet("Allow", "Deny")]
[string]$WDACAction = "Allow"
[bool]$WDACDCS = $True # True, False

# Port forward RDP access to the lab machine to make it accessible externally
#$LPORT = "3490"
#$RHOST = "10.10.X.3"

#netsh interface portproxy add v4tov4 listenport=$LPORT listenaddress=0.0.0.0 connectport=3389 connectaddress=$RHOST

#--------------------------------------------------------------------------------------------------------------------
# CUSTOMROLE INSTLLATION
$ALCustomRolesFilePath = $labSources + '\CustomRoles'

# Copy the subdirectories of CustomRoles to the lab sources
Copy-Item -Path "C:\AutomatedBadLab\CustomRoles\*" -Destination $ALCustomRolesFilePath -Recurse -ErrorAction SilentlyContinue

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# For Internal networks, just need a name and subnet space. Internet Network is a static NAT network
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace $Subnet
Add-LabVirtualNetworkDefinition -Name 'Internet' -AddressSpace 10.10.0.0/24 # REMOVE IF INTERNAL ONLY

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
$WS1NICs = @()
$WS1NICs += New-LabNetworkAdapterDefinition -VirtualSwitch $LabName
$WS1NICs += New-LabNetworkAdapterDefinition -VirtualSwitch 'Internet' -UseDhcp # REMOVE IF INTERNAL ONLY

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/

# Install Windows Defender Application Control Custom Role
$WDACRole = Get-LabPostInstallationActivity -CustomRole WindowsDefenderApplicationControl -Properties @{
    Action = $WDACAction
    DCS = $WDACDCS
}

Add-LabMachineDefinition -Name $MachineName -NetworkAdapter $WS1NICs -PostInstallationActivity $WDACRole

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary -Detailed