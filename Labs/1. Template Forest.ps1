#--------------------------------------------------------------------------------------------------------------------
# CHANGEME - Global parameters
$LabName        = 'EnterpriseLab'
$Subnet         = '10.10.X.0/24'

# CHANGEME - Credential parameters
$DomainUser     = 'domadmin'
$DomainPass     = 'complexpassword'

# CHANGEME - Domain parameters
$RootDomain     = 'evilcorp.com'
$ChildDomain    = 'eu.evilcorp.com'
$SecondDomain   = 'us.allsafe.com'

$RootDC         = 'ECDC01'
$RootCA         = 'ECCA01'
$ChildDC        = 'ECEUDC02'
$SecondDC       = 'ASDC01'

# CHANGEME - Certificate Authority parameters
$CAName         = 'EvilCorpCA'

# CHANGEME - Operating System parameters
$OSVersion      = 'Windows Server 2022 Standard Evaluation' # Core has less footprint

# Domain Hash Table
$DCDictionary = @{
    $RootDC     = $RootDomain
    $ChildDC    = $ChildDomain
    $SecondDC   = $SecondDomain
}

# Path to our custom provisioning scripts
$CustomScripts  = 'C:\AutomatedBadLab\PostInstallationActivities'

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# LAB ACCOUNTS
Set-LabInstallationCredential -Username $DomainUser -Password $DomainPass
Add-LabDomainDefinition -Name $RootDomain -AdminUser $DomainUser -AdminPassword $DomainPass
Add-LabDomainDefinition -Name $ChildDomain -AdminUser $DomainUser -AdminPassword $DomainPass
Add-LabDomainDefinition -Name $SecondDomain -AdminUser $DomainUser -AdminPassword $DomainPass

# NETWORKING
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace $Subnet

#--------------------------------------------------------------------------------------------------------------------
# Defining default parameter values, as these ones are the same for all the machines. 
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $labName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
    'Add-LabMachineDefinition:OperatingSystem'  = $OSVersion
}

#--------------------------------------------------------------------------------------------------------------------
# CA ROLE
# Create the CA
$CARole = Get-LabMachineRoleDefinition -Role CaRoot @{
    CACommonName        = $CAName
    KeyLength           = '4096'
    ValidityPeriod      = 'Years'
    ValidityPeriodUnits = '20'
}

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION

# Forest A Root Domain Controller
Add-LabMachineDefinition -Name $RootDC -Roles RootDC -DomainName $RootDomain

# Forest A Certificate Authority
Add-LabMachineDefinition -Name $RootCA -Roles $CARole -DomainName $RootDomain

# Forest A Child Domain Controller
Add-LabMachineDefinition -Name $ChildDC -Roles FirstChildDC -DomainName $ChildDomain

# Forest B Root Domain Controller
Add-LabMachineDefinition -Name $SecondDC -Roles RootDC -DomainName $SecondDomain

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

#--------------------------------------------------------------------------------------------------------------------
# ADCS Provisioning
Write-ScreenInfo "Creating Insecure ADCS Templates"
. "$CustomScripts\AutomatedBadLab\ADCS_Attack_Vectors\New-WeakADCSTemplates.ps1"
New-WeakADCSTemplates

Write-ScreenInfo "Enabling Auto-enrollment for Certificates"
Enable-LabCertificateAutoenrollment -Computer -User -CodeSigning

# Array to house vulnerable users from each domain
$VulnUsers = @()

# ADDS Provisioning
foreach ($DC in $DCDictionary.GetEnumerator()) {
    Write-ScreenInfo "Creating GPPPassword files on $($DC.Name)"
    Copy-LabFileItem -ComputerName $DC.Name -Recurse -Path $CustomScripts\AutomatedBadLab\AD_Attack_Vectors\GPPPassword\ -Destination "C:\Windows\Sysvol\sysvol\$($DC.Value)\Policies"

    Write-ScreenInfo "Creating Domain structure and objects via AutomatedBadLab on $($DC.Value)"
    Start-Transcript -Append -Path "$CustomScripts\AutomatedBadLab\$($DC.Value)_$(Get-Date -f 'yyyy_MM_dd')_AutomatedBadLab.log"
    $VulnUsers += Invoke-LabCommand -ComputerName $DC.Name -ActivityName InvokeAutomatedBadLab -FileName Invoke-AutomatedBadLab.ps1 -DependencyFolderPath $CustomScripts\AutomatedBadLab -PassThru
    Stop-Transcript
}

# Remove other returned objects we don't want
$VulnUsers = $VulnUsers | Where-Object { $_.ObjectClass -eq 'user' }

# Trust Provisioning
foreach ($DC in $DCDictionary.GetEnumerator()) {
    Start-Transcript -Append -Path "$CustomScripts\AutomatedBadLab\$($DC.Value)_$(Get-Date -f 'yyyy_MM_dd')_AutomatedBadLab.log"
    Invoke-LabCommand -ComputerName $DC.Name -ActivityName CreateForeignMemberships -FileName Add-ForeignMemberships.ps1 `
    -DependencyFolderPath $CustomScripts\AutomatedBadLab\Trust_Attack_Vectors -Variable (Get-Variable -Name VulnUsers)
    Stop-Transcript

    Write-ScreenInfo "Taking a snapshot of $($DC.Name) in its provisioned state"
    Checkpoint-LabVM -ComputerName $DC.Name -SnapshotName "$(Get-Date) - $($DC.Name) AutomatedBadLab Complete"
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
