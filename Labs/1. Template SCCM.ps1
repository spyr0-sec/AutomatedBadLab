#--------------------------------------------------------------------------------------------------------------------
# CHANGEME - Global parameters
$LabName        = 'SCCMTemplate'

# CHANGEME - Active Directory parameters
$DomainUser     = 'sccmadmin'
$DomainPass     = 'complexpassword'
$Domain         = 'sccm.local'

# CHANGEME - Certificate Authority parameters
$CAName         = 'SCCMCA'

# CHANGEME - Configuration Manager parameters
$CMVersion      = '2103' # 2203, 2103, 2002, 1902
$CMRoles        = 'Management Point,Distribution Point,Software Update Point,Reporting Services Point,Endpoint Protection Point'
$CMSiteName     = 'London'
$CMSiteCode     = 'LD1'
$CMDBName       = 'CMDB'

#--------------------------------------------------------------------------------------------------------------------
# CUSTOMROLE INSTALLATION
$ABLCustomRolesFilePath = Join-Path $PSScriptRoot "..\CustomRoles"

# Copy the subdirectories of CustomRoles to the lab sources
Copy-Item -Path $ABLCustomRolesFilePath -Destination $labSources -Force -Recurse

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV -ReferenceDiskSizeInGB 100

# Create a domain admin account to handle Windows machine creation / Active Directory configration.
# NOTE: Make sure these passwords are the same and needs to be complex
Add-LabDomainDefinition -Name $Domain -AdminUser $DomainUser -AdminPassword $DomainPass
Set-LabInstallationCredential -Username $DomainUser -Password $DomainPass

# Use the wizard to download the SQL Server 2019 ISO - https://www.microsoft.com/en-us/evalcenter/download-sql-server-2019
Add-LabIsoImageDefinition -Name 'SQLServer2019' -Path "$labSources\ISOs\SQLServer2019-x64-ENU.iso"

# Use NetNat to provide Internet access within an isolated network
Add-LabVirtualNetworkDefinition -Name $LabName -UseNat

#--------------------------------------------------------------------------------------------------------------------
# Defining default parameter values, as these ones are the same for all the machines.
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $LabName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:DomainName'       = $Domain
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = 'Windows Server 2025 Standard Evaluation (Desktop Experience)'
}

#--------------------------------------------------------------------------------------------------------------------
# Domain Controller provisioning
$DCRole = Get-LabMachineRoleDefinition -Role RootDC @{
    SiteName   = $CMSiteName
    SiteSubnet = $Subnet
}

# Certificate Authority provisioning
$CARole = Get-LabMachineRoleDefinition -Role CaRoot @{
    CACommonName        = $CAName
    KeyLength           = '4096'
    ValidityPeriod      = 'Years'
    ValidityPeriodUnits = '20'
}

Add-LabMachineDefinition -Name CMDC01 -Roles $DCRole, $CARole

# Database Server provisioning
$DBRole = Get-LabMachineRoleDefinition -Role SQLServer2019 -Properties @{
    Collation = 'SQL_Latin1_General_CP1_CI_AS'
}

Add-LabMachineDefinition -Name CMDB01 -Roles $DBRole

# Configuration Manager Provisioning
# For possible Syntax, refer to Get-LabMachineRoleDefinition -Role ConfigurationManager -Syntax
$CMRole = Get-LabMachineRoleDefinition -Role ConfigurationManager -Properties @{
    Version      = $CMVersion
    Roles        = $CMRoles
    SiteName     = $CMSiteName
    SiteCode     = $CMSiteCode
    DatabaseName = $CMDBName
}
Add-LabMachineDefinition -Name CMCM01 -Roles $CMRole

# Workstation Provisioning
$WS1PostInstallJobs = @() # Will execute in order
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience

# For the workstation, use Get-LabAvailableOperatingSystem to get correct OS name
Add-LabMachineDefinition -Name CMWS01 -PostInstallationActivity $WS1PostInstallJobs -OperatingSystem 'Windows 10 Enterprise Evaluation'

# Install our lab, has flags for level of output
Install-Lab #-Verbose -Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary
