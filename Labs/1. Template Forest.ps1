#--------------------------------------------------------------------------------------------------------------------
# CHANGEME - Global parameters
$LabName         = 'EnterpriseLab'
$Subnet          = '10.10.X.0/24'

# CHANGEME - Credential parameters
$DomainUser      = 'domadmin'
$DomainPass      = 'complexpassword'

# CHANGEME - Domain parameters
$RootDomain      = 'evilcorp.com'
$ChildDomain     = 'eu.evilcorp.com'
$SecondDomain    = 'us.allsafe.com'

$RootDC          = 'ECDC01'
$RootCA          = 'ECCA01'
$ChildDC         = 'ECEUDC02'
$SecondDC        = 'ASDC01'

# CHANGEME - Certificate Authority parameters
$CAName          = 'EvilCorpCA'

# CHANGEME - Operating System parameters
$OperatingSystem = 'Windows Server 2022 Standard Evaluation' # Core has less footprint

# Domain Hash Table
$DCDictionary = @{
    $RootDC     = $RootDomain
    $ChildDC    = $ChildDomain
    $SecondDC   = $SecondDomain
}

# Path to our custom provisioning scripts
$ABLPostInstallActivitiesFilePath  = Join-Path $PSScriptRoot "..\PostInstallationActivities"

#--------------------------------------------------------------------------------------------------------------------
# CUSTOMROLE INSTALLATION
$ABLCustomRolesFilePath = Join-Path $PSScriptRoot "..\CustomRoles"

# Copy the subdirectories of CustomRoles to the lab sources
Copy-Item -Path $ABLCustomRolesFilePath -Destination $labSources -Force -Recurse

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# LAB ACCOUNTS
Set-LabInstallationCredential -Username $DomainUser -Password $DomainPass
Add-LabDomainDefinition -Name $RootDomain -AdminUser $DomainUser -AdminPassword $DomainPass
Add-LabDomainDefinition -Name $ChildDomain -AdminUser $DomainUser -AdminPassword $DomainPass
Add-LabDomainDefinition -Name $SecondDomain -AdminUser $DomainUser -AdminPassword $DomainPass

# NETWORKING - Simple flat internal network
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace $Subnet

#--------------------------------------------------------------------------------------------------------------------
# Defining default parameter values, as these ones are the same for all the machines. 
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $labName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = $OperatingSystem
}

#--------------------------------------------------------------------------------------------------------------------
# CA ROLE

$CARole = Get-LabMachineRoleDefinition -Role CaRoot @{
    CACommonName        = $CAName
    KeyLength           = '4096'
    ValidityPeriod      = 'Years'
    ValidityPeriodUnits = '20'
}

# AUTOMATEDBADLAB ROLES
$AutomatedBadLabRole = Get-LabPostInstallationActivity -CustomRole AutomatedBadLab

$AutomatedBadLabADCSRole = Get-LabPostInstallationActivity -CustomRole AutomatedBadLabADCS

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION

# Forest A Root Domain Controller
Add-LabMachineDefinition -Name $RootDC -Roles RootDC -DomainName $RootDomain -PostInstallationActivity $AutomatedBadLabRole

# Forest A Certificate Authority
Add-LabMachineDefinition -Name $RootCA -Roles $CARole -DomainName $RootDomain -PostInstallationActivity $AutomatedBadLabADCSRole

# Forest A Child Domain Controller
Add-LabMachineDefinition -Name $ChildDC -Roles FirstChildDC -DomainName $ChildDomain -PostInstallationActivity $AutomatedBadLabRole

# Forest B Root Domain Controller
Add-LabMachineDefinition -Name $SecondDC -Roles RootDC -DomainName $SecondDomain -PostInstallationActivity $AutomatedBadLabRole

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

#--------------------------------------------------------------------------------------------------------------------
# Trust Provisioning
foreach ($DC in $DCDictionary.GetEnumerator()) {
    Invoke-LabCommand -ComputerName $DC.Name -ActivityName CreateForeignMemberships -FileName Add-ForeignMemberships.ps1 `
    -DependencyFolderPath $ABLPostInstallActivitiesFilePath\AutomatedBadLabTrusts
    # Retrieve logs from each DC
    $DC = Get-LabVM -ComputerName $DC.Name
    $DCSession = New-LabPSSession -ComputerName $DC.Name
    Receive-File -SourceFilePath C:\AutomatedBadLab.log -DestinationFilePath "$PSScriptRoot\$($DC.DomainName)_AutomatedBadLab.log" -Session $DCSession
    Remove-LabPSSession -ComputerName $DC.Name
    Write-ScreenInfo "Downloaded logs to $PSScriptRoot\$($DC.DomainName)_AutomatedBadLab.log"
}

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary -Detailed

<# Debugging - Remove all objects created by AutomatedBadLab
foreach ($DC in $DCDictionary.GetEnumerator()) {
    Invoke-LabCommand -ComputerName $DC.Name -ActivityName RemoveAutomatedBadLab -FileName Remove-AllBLADObjects -DependencyFolderPath $CustomScripts\AutomatedBadLab\AD_Delete_All
}

Write-ScreenInfo "Removing Insecure ADCS Templates" # Runs locally
. "$CustomScripts\AutomatedBadLab\ADCS_Delete_All\Remove-AllBLADCSObjects.ps1"
Remove-AllBLADCSObjects
#>
