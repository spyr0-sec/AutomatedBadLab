#--------------------------------------------------------------------------------------------------------------------
# Global parameters - CHANGEME
$LabName         = 'DevBoxTemplate'
$AdminUser       = 'devadmin'
$AdminPass       = 'complexpassword'
$MachineName     = 'DevBox'

# Get-LabAvailableOperatingSystem will list all available OSes to you
$OperatingSystem = 'Windows 11 Enterprise Evaluation'

#--------------------------------------------------------------------------------------------------------------------
# LAB CREATION
# Create our lab using HyperV (Azure is also supported)
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine HyperV

# Create a local admin account
Set-LabInstallationCredential -Username $AdminUser -Password $AdminPass

#--------------------------------------------------------------------------------------------------------------------
# DEFAULT MACHINE PARAMETERS
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network'          = $labName
    'Add-LabMachineDefinition:ToolsPath'        = "$labSources\Tools"
    'Add-LabMachineDefinition:MinMemory'        = 1GB
    'Add-LabMachineDefinition:Memory'           = 4GB
    'Add-LabMachineDefinition:MaxMemory'        = 8GB
}

#--------------------------------------------------------------------------------------------------------------------
# NETWORKING - https://automatedlab.org/en/latest/Wiki/Basic/networksandaddresses/
$VSwitch = Get-VMSwitch | Where-Object SwitchType -eq 'External'
Add-LabVirtualNetworkDefinition -Name $VSwitch.Name -HyperVProperties @{
    SwitchType = $VSwitch.SwitchType
    AdapterName = $VSwitch.NetAdapterInterfaceDescription
}

#--------------------------------------------------------------------------------------------------------------------
# MACHINE CREATION - https://automatedlab.org/en/latest/Wiki/Basic/addmachines/
$InstallJobs = @()
$InstallJobs += Get-LabPostInstallationActivity -CustomRole VisualStudio2022
$InstallJobs += Get-LabPostInstallationActivity -CustomRole VisualStudioCode

Add-LabMachineDefinition -Name $MachineName -Network $VSwitch.Name -OperatingSystem $OperatingSystem -PostInstallationActivity $InstallJobs

# Install our lab, has flags for level of output
Install-Lab # -Verbose -Debug

# UX+++ (https://twitter.com/awakecoding/status/1750736577746084162)
Invoke-LabCommand -ComputerName (Get-LabVM) -ActivityName "RemoveFirstRunExperience" -ScriptBlock {
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Edge" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "NewTabPageLocation" -Value "https://google.com"
}

# Provides a pretty table detailing all elements of what has been created
Show-LabDeploymentSummary -Detailed
