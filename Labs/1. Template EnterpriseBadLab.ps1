#--------------------------------------------------------------------------------------------------------------------
# CHANGEME - Global parameters
$LabName        = 'EnterpriseBadLab'

# CHANGEME - Active Directory parameters
$DomainUser     = 'domadmin'
$DomainPass     = 'Compl£xPa$$word123!'
$Domain         = 'bad.lab'

# CHANGEME - Certificate Authority parameters
$CAName         = 'BadCA'

# CHANGEME - Configuration Manager parameters
$CMVersion      = '2203' # 2203, 2103, 2002, 1902
$CMRoles        = 'Management Point,Distribution Point,Software Update Point,Reporting Services Point,Endpoint Protection Point'
$CMSiteName     = 'London'
$CMSiteCode     = 'LD1'
$CMDBName       = 'CMDB'

# CHANGEME - ProvisionSCCM parameters
$ProvisionUserCount = 20

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
$DC1PostInstallJobs = @() # Will execute in order
$DC1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole AutomatedBadLab

Add-LabMachineDefinition -Name BBDC01 -Roles RootDC -PostInstallationActivity $DC1PostInstallJobs

# Certificate Authority provisioning
# NOTE: -Properties must be explicit on AutomatedLab 5.61 (positional hashtable binding was
#       removed) - without it $CARole is $null and BBCA01 silently loses the CA role!
$CARole = Get-LabMachineRoleDefinition -Role CaRoot -Properties @{
    CACommonName        = $CAName
    KeyLength           = '4096'
    ValidityPeriod      = 'Years'
    ValidityPeriodUnits = '20'
}

$CA1PostInstallJobs = @() # Will execute in order
$CA1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole AutomatedBadLabADCS

Add-LabMachineDefinition -Name BBCA01 -Roles $CARole -PostInstallationActivity $CA1PostInstallJobs

# Database Server provisioning
$DBRole = Get-LabMachineRoleDefinition -Role SQLServer2019 -Properties @{
    Collation = 'SQL_Latin1_General_CP1_CI_AS'
}

# NOTE: Pinned to Server 2022 - SQL 2019 RTM is not in the Server 2025 support matrix
Add-LabMachineDefinition -Name BBDB01 -Roles $DBRole -OperatingSystem 'Windows Server 2022 Standard Evaluation (Desktop Experience)'

# Configuration Manager Provisioning
# For possible Syntax, refer to Get-LabMachineRoleDefinition -Role ConfigurationManager -Syntax
# NOTE: SqlServerName is not set on purpose - the CM role auto-picks the first SQL2014/16/17/19
#       machine in the lab (AutomatedLabCore 10822-10832) = BBDB01
$CMRole = Get-LabMachineRoleDefinition -Role ConfigurationManager -Properties @{
    Version      = $CMVersion
    Roles        = $CMRoles
    SiteName     = $CMSiteName
    SiteCode     = $CMSiteCode
    DatabaseName = $CMDBName
}

# NOTE: Pinned to Server 2022 - CM 2203 does not support Server 2025 site systems
$CM1PostInstallJobs = @() # Will execute in order
$CM1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole AutomatedLabSCCM -Properties @{
    SiteCode = $CMSiteCode
}
$CM1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole ProvisionSCCM -Properties @{
    SiteCode     = $CMSiteCode
    UserCount    = $ProvisionUserCount
}

Add-LabMachineDefinition -Name BBCM01 -Roles $CMRole -PostInstallationActivity $CM1PostInstallJobs -OperatingSystem 'Windows Server 2022 Standard Evaluation (Desktop Experience)'

# AD Federation Server provisioning
# NOTE: ADFS role defaults (AutomatedLab 5.61 Install-LabAdfs): farm display name 'AdfsBad',
#       service account 'bad\AdfsService' (password 'Somepass1'), SSL cert subject
#       CN=adfs.bad.lab (SANs adfs.bad.lab + enterpriseregistration.bad.lab) issued from BBCA01.
Add-LabMachineDefinition -Name BBADFS01 -Roles ADFS

# NOTE: The ADFSProxy role reads Properties.AdfsFullName / Properties.AdfsDomainName with no
#       defaults (AutomatedLabCore Install-LabAdfsProxy) - without these, the cert lookup on
#       the ADFS server fails and the proxy is never configured.
$ADFSProxyRole = Get-LabMachineRoleDefinition -Role ADFSProxy -Properties @{
    AdfsFullName   = "adfs.$Domain"
    AdfsDomainName = $Domain
}

Add-LabMachineDefinition -Name BBADFSProxy01 -Roles $ADFSProxyRole

# Workstation provisioning
$WS1PostInstallJobs = @() # Will execute in order
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveFirstRunExperience
$WS1PostInstallJobs += Get-LabPostInstallationActivity -CustomRole RemoveWindowsDefender

# For the workstation, use Get-LabAvailableOperatingSystem to get correct OS name
Add-LabMachineDefinition -Name BBWS01 -PostInstallationActivity $WS1PostInstallJobs -OperatingSystem 'Windows 11 Enterprise Evaluation'

# Install our lab, has flags for level of output
Install-Lab -Verbose #-Debug

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary
