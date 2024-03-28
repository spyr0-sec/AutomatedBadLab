param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name

Install-LabWindowsFeature -ComputerName $ComputerName -FeatureName Windows-Defender-ApplicationGuard

Invoke-LabCommand -ComputerName $ComputerName -ActivityName "Remove Hardware Restrictions" -ScriptBlock {
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Hvsi -Name SpecRequiredProcessorCount -PropertyType DWORD -Value 1
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Hvsi -Name SpecRequiredMemoryInGB -PropertyType DWORD -Value 2
}
