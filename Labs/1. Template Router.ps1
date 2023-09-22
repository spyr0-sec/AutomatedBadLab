#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName                = "Router"

# Computer parameters
$RouterUser             = "routeradmin"
$RouterPass             = "complexpassword"
$RouterName             = "Router01"
$RouterOperatingSystem  = 'Windows Server 2019 Standard Evaluation (Desktop Experience)'

# Network parameters
$NetworkName            = "Internet"
$AddressSpace           = "10.10.0.0/24"
$Gateway                = "10.10.0.1"
$DNSServer              = "8.8.8.8"
$ClassC                 = ($AddressSpace -split "/")[0] -replace "\.\d$", ""

# Path to our custom provisioning scripts
$CustomScripts = "C:\AutomatedBadLab\PostInstallationActivities"

#--------------------------------------------------------------------------------------------------------------------

# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# This network needs to be created during this process otherwise there are IP conflicts
Add-LabVirtualNetworkDefinition -Name $NetworkName -AddressSpace $AddressSpace

# User account
Set-LabInstallationCredential -Username $RouterUser -Password $RouterPass

#--------------------------------------------------------------------------------------------------------------------
# Defining default parameter values, as these ones are the same for all the machines. 
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $NetworkName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = $RouterOperatingSystem
    'Add-LabMachineDefinition:Gateway'          = $Gateway
    'Add-LabMachineDefinition:DnsServer1'       = $DNSServer
}

#--------------------------------------------------------------------------------------------------------------------
# Create the Windows Server (DHCP role to be configured Post-Install)
Add-LabMachineDefinition -Name $RouterName

#--------------------------------------------------------------------------------------------------------------------
# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

# Configure NAT locally on newly created local vNetwork
If (-not (Get-NetIPAddress -IPAddress $Gateway -ErrorAction SilentlyContinue)) {
    Write-ScreenInfo -Message "Configuring local $NetworkName vNetwork with NAT to permit outbound lab traffic"
    New-NetIPAddress -IPAddress $Gateway -PrefixLength 24 -InterfaceIndex (Get-NetAdapter -Name "vEthernet ($NetworkName)").ifIndex
    New-NetNat -Name Gateway -InternalIPInterfaceAddressPrefix $AddressSpace
}

# Configure DHCP Scope
Invoke-LabCommand -ActivityName "Configure DHCP" -ComputerName (Get-LabVM) -ScriptBlock {
    param($ClassC, $Gateway, $DNSServer)

    Install-WindowsFeature -Name "DHCP" -IncludeManagementTools
    Add-DhcpServerv4Scope -Name "External" -Description "Provide DHCP addresses to AutomatedLab Outbound Network" -StartRange "$($ClassC).100" -EndRange "$($ClassC).200" -SubnetMask 255.255.255.0
    Set-DhcpServerv4OptionValue -ScopeId "$($ClassC).0" -OptionId 3 -Value $Gateway # Router
    Set-DhcpServerv4OptionValue -ScopeId "$($ClassC).0" -OptionId 6 -Value $DNSServer -Force # DNS
    New-LocalGroup -Name "DHCP Administrators" -Description "Full control of the DHCP Server."
    New-LocalGroup -Name "DHCP Users" -Description "Members who have view-only access to the DHCP service"
} -ArgumentList $ClassC, $Gateway, $DNSServer

# Update Windows
Invoke-LabCommand -ComputerName (Get-LabVM) -ActivityName UpdateWindows -FileName 'Update-Windows.ps1' -DependencyFolderPath $CustomScripts\UpdateWindows

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary -Detailed
