param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

# Import Lab
Import-Lab -Name $data.Name -NoValidation -NoDisplay

# Add Defender exclusion before uploading the script (won't work if Defender has already been destroyed)
Invoke-LabCommand -ComputerName $ComputerName -ActivityName "Add AV Exclusions" -ScriptBlock { 
    New-Item -ItemType Directory -Path "C:\OffensivePipeline\Temp" -Force
    Add-MpPreference -ExclusionPath "C:\OffensivePipeline"
    Add-MpPreference -ExclusionExtension “exe”
    Add-MpPreference -ExclusionExtension “bin”
}

Install-LabWindowsFeature -ComputerName $ComputerName -FeatureName NET-Framework-Core
