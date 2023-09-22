#--------------------------------------------------------------------------------------------------------------------
# CHANGEME - Global parameters
$LabName        = 'LabTemplate'
$Subnet         = '10.10.X.0/24'

# CHANGEME - Active Directory parameters
$DomainUser     = 'domainadmin'
$DomainPass     = 'complexpassword'
$Domain         = 'domain.tld' 
$DCIP           = '10.10.X.10'

# Path to our custom provisioning scripts
$CustomScripts  = 'C:\AutomatedBadLab\PostInstallationActivities'

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# For Internal networks, just need a name and subnet space. Internet Network is a static NAT network
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace $Subnet
Add-LabVirtualNetworkDefinition -Name 'Internet' -AddressSpace 10.10.0.0/24 # REMOVE IF INTERNAL ONLY

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
    'Add-LabMachineDefinition:Network'          = $labName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:DomainName'       = $Domain 
    'Add-LabMachineDefinition:DnsServer1'       = $DCIP
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = 'Windows Server 2019 Standard Evaluation (Desktop Experience)'
}

#--------------------------------------------------------------------------------------------------------------------
# POST INSTALLATION ACTIVITIES - https://automatedlab.org/en/latest/Wiki/Basic/invokelabcommand/
# Recommend Invoke-LabCommand to run PowerShell commands on the Lab VMs after Install-Lab rather than PostInstallActivities

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
# NETWORKING - https://automatedlab.org/en/latest/Wiki/Basic/networksandaddresses/
# Give Workstation Internet access via NAT switch
$WS1NICs = @()
$WS1NICs += New-LabNetworkAdapterDefinition -VirtualSwitch $LabName
$WS1NICs += New-LabNetworkAdapterDefinition -VirtualSwitch 'Internet' -UseDhcp

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/
# Create the machine definition with its custom name, networking, Roles and Post-install activities
Add-LabMachineDefinition -Name DC01 -Roles RootDC -IpAddress $DCIP -PostInstallationActivity $ADPrep

# For the workstation, use Get-LabAvailableOperatingSystem to get correct OS name
Add-LabMachineDefinition -Name WS01 -NetworkAdapter $WS1NICs -OperatingSystem 'Windows 10 Enterprise Evaluation'

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

#--------------------------------------------------------------------------------------------------------------------
# RUNNING COMMANDS
# Create a library of common PowerShell scripts you may want to run such as updating Windows
Invoke-LabCommand -ComputerName (Get-LabVM) -ActivityName UpdateWindows -FileName 'Update-Windows.ps1' -DependencyFolderPath $CustomScripts\UpdateWindows

# FILE TRANSFER BETWEEN HOST AND GUEST - https://automatedlab.org/en/latest/Wiki/Basic/exchangedata/
# Example - Disabling Windows Defender via a batch file

# Add Defender exclusion before uploading the script
Invoke-LabCommand -ComputerName (Get-LabVM) -ActivityName AddExclusions -ScriptBlock { Set-MpPreference -ExclusionPath "C:\Windows\Temp"; Set-MpPreference -ExclusionExtension "bat" }

# Upload Batch file to remove Windows Defender
Copy-LabFileItem -ComputerName (Get-LabVM) -Path $CustomScripts\RemoveWindowsDefender\RemoveWindowsDefender.bat -Destination "C:\Windows\Temp"

# Run the batch file as TrustedInstaller via Scheduled Task
Invoke-LabCommand -ComputerName (Get-LabVM) -ActivityName RemoveDefender -FileName 'Remove-WindowsDefender.ps1' -DependencyFolderPath $CustomScripts\RemoveWindowsDefender

#--------------------------------------------------------------------------------------------------------------------
# INSTALLING SOFTWARE / FEATURES - https://automatedlab.org/en/latest/Wiki/Basic/installsoftware/
# Install software on all Lab VMs - Use SilentHQ / Google to find correct flags
Install-LabSoftwarePackage -ComputerName (Get-LabVM) -Path $labSources\SoftwarePackages\Git.exe -CommandLine '/VERYSILENT /NORESTART'

# Install RSAT just on workstation
Install-LabWindowsFeature -FeatureName RSAT -ComputerName WS01 -IncludeAllSubFeature

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary -Detailed