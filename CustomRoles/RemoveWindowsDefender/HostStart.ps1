param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name -NoValidation

# Add Defender exclusion before uploading the script
Invoke-LabCommand -ComputerName $ComputerName -ActivityName "Add AV Exclusions" -ScriptBlock { 
    Set-MpPreference -ExclusionPath "C:\Windows\Temp"
    Add-MpPreference -ExclusionExtension "bat" 
}

# Upload Batch file to remove Windows Defender
Copy-LabFileItem -ComputerName $ComputerName -Path "$labSources\CustomRoles\RemoveWindowsDefender\RemoveWindowsDefender.bat" -Destination "C:\Windows\Temp"
