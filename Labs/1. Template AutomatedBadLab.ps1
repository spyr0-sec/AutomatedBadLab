#--------------------------------------------------------------------------------------------------------------------
# CHANGEME - Global parameters
$LabName        = 'AutomatedBadLab'
$Subnet         = '10.10.X.0/24'

# CHANGEME - Active Directory parameters
$DomainUser     = 'domainadmin'
$DomainPass     = 'complexpassword'
$Domain         = 'domain.tld' 
$DCIP           = '10.10.X.10'

# CHANGEME - Certificate Authority parameters
$CAName         = 'AutomatedBadLabCA'

# Path to our custom provisioning scripts
$CustomScripts  = 'C:\AutomatedBadLab\PostInstallationActivities'

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# For Internal networks, just need a name and subnet space. Internet Network is a static NAT network
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace $Subnet
Add-LabVirtualNetworkDefinition -Name "Internet" -AddressSpace 10.10.0.0/24 # REMOVE IF INTERNAL ONLY

# Create a domain admin account to handle Windows machine creation / Active Directory configration. 
# NOTE: Make sure these passwords are the same and needs to be complex
Add-LabDomainDefinition -Name $Domain -AdminUser $DomainUser -AdminPassword $DomainPass
Set-LabInstallationCredential -Username $DomainUser -Password $DomainPass

#--------------------------------------------------------------------------------------------------------------------
# Defining default parameter values, as these ones are the same for all the machines. 
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
# Create the DC with custom name and IP parameters

# Give both machines Internet access to download updates
$DC1NICs = @()
$DC1NICs += New-LabNetworkAdapterDefinition -VirtualSwitch $LabName -Ipv4Address $DCIP
$DC1NICs += New-LabNetworkAdapterDefinition -VirtualSwitch 'Internet' -UseDhcp

Add-LabMachineDefinition -Name BLDC01 -Roles RootDC -NetworkAdapter $DC1NICs

# Create the CA
$CARole = Get-LabMachineRoleDefinition -Role CaRoot @{
    CACommonName        = $CAName
    KeyLength           = '4096'
    ValidityPeriod      = 'Years'
    ValidityPeriodUnits = '20'
}

Add-LabMachineDefinition -Name BLCA01 -Roles $CARole

# Give Workstation Internet access via NAT switch
$WS1NICs = @()
$WS1NICs += New-LabNetworkAdapterDefinition -VirtualSwitch $LabName
$WS1NICs += New-LabNetworkAdapterDefinition -VirtualSwitch 'Internet' -UseDhcp

# For the workstation, use Get-LabAvailableOperatingSystem to get correct OS name
Add-LabMachineDefinition -Name BLWS01 -NetworkAdapter $WS1NICs -OperatingSystem 'Windows 10 Enterprise Evaluation'

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

#--------------------------------------------------------------------------------------------------------------------
# Need to update Evaluation OS versions to > April 2023 for LAPS. Can remove if using more up to date ISOs

Write-ScreenInfo "Updating Windows"
$UpdateVMs = @('BLDC01', 'BLWS01')
Invoke-LabCommand -ComputerName $UpdateVMs -ActivityName UpdateWindows -FileName 'Update-Windows.ps1' -DependencyFolderPath $CustomScripts\UpdateWindows

# Create a hashtable to store initial uptimes for each VM
$initialUptimes = @{}

# Populate the hashtable with the initial uptimes
foreach ($vmName in $UpdateVMs) {
    $initialUptimes[$vmName] = (Get-VM -Name $vmName).Uptime
}

foreach ($vmName in $UpdateVMs) {
    Write-ScreenInfo "Waiting for $vmName to restart..."

    do {
        Write-Progress -Id 1 -Activity "Updating Windows" -Status "Waiting for Reboot" 
        Start-Sleep -Seconds 60
        $currentUptime = (Get-VM -Name $vmName).Uptime

        # If current uptime is less than the initial uptime, the VM has restarted
    } while ($currentUptime -ge $initialUptimes[$vmName])

    Write-ScreenInfo "$vmName has restarted!"
}

Write-Progress -Id 1 -Activity "Updating Windows" -Status "Completed" -PercentComplete 100 -Completed
Write-ScreenInfo "Waiting five minutes for the machines to become active again before continuing"
Start-Sleep -Seconds 300

#--------------------------------------------------------------------------------------------------------------------

Write-ScreenInfo "Creating GPPPassword files"
Copy-LabFileItem -ComputerName BLDC01 -Recurse -Path $CustomScripts\AutomatedBadLab\AD_Attack_Vectors\GPPPassword\ -Destination "C:\Windows\Sysvol\sysvol\$Domain\Policies"

Write-ScreenInfo "Creating Domain structure and objects via AutomatedBadLab"
Start-Transcript -Append -Path "$CustomScripts\AutomatedBadLab\$(Get-Date -f 'yyyy_MM_dd')_AutomatedBadLab.log"
Invoke-LabCommand -ComputerName BLDC01 -ActivityName InvokeAutomatedBadLab -FileName Invoke-AutomatedBadLab.ps1 -DependencyFolderPath $CustomScripts\AutomatedBadLab
Stop-Transcript

Write-ScreenInfo "Creating Insecure ADCS Templates"
. "$CustomScripts\AutomatedBadLab\ADCS_Attack_Vectors\New-WeakADCSTemplates.ps1"
New-WeakADCSTemplates

# Add Defender exclusion before uploading the Windows Defender removal script
Invoke-LabCommand -ComputerName BLWS01 -ActivityName AddExclusions -ScriptBlock { Set-MpPreference -ExclusionPath "C:\Windows\Temp"; Set-MpPreference -ExclusionExtension "bat" }

# Upload Batch file to remove Windows Defender
Copy-LabFileItem -ComputerName BLWS01 -Path $CustomScripts\RemoveWindowsDefender\RemoveWindowsDefender.bat -Destination "C:\Windows\Temp"

# Run the batch file as TrustedInstaller via Scheduled Task
Invoke-LabCommand -ComputerName BLWS01 -ActivityName RemoveDefender -FileName 'Remove-WindowsDefender.ps1' -DependencyFolderPath $CustomScripts\RemoveWindowsDefender

<# Debugging - Remove all objects created by AutomatedBadLab
Invoke-LabCommand -ComputerName BBDC01 -ActivityName RemoveAutomatedBadLab -FileName Remove-AllBLADObjects -DependencyFolderPath $CustomScripts\AutomatedBadLab\AD_Delete_All

Write-ScreenInfo "Removing Insecure ADCS Templates" # Runs locally
. "$CustomScripts\AutomatedBadLab\ADCS_Delete_All\Remove-AllBLADCSObjects.ps1"
Remove-AllBLADCSObjects
#>

Write-ScreenInfo "Enabling Auto-enrollment for Certificates"
Enable-LabCertificateAutoenrollment -Computer -User -CodeSigning

# Take a snapshot of the DC in a working state
Checkpoint-LabVM -ComputerName BBDC01 -SnapshotName "$(Get-Date) - AutomatedBadLab Complete"

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary -Detailed
