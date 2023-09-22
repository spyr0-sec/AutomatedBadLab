## Remove Windows Defender
!!! DO NOT USE ON A PRODUCTION SYSTEM. THIS DELETES MANY SYSTEM FILES !!!

Windows Defender takes some convincing to remove so this has to be done in three parts:

1. Set up exclusions before uploading the .bat file
2. Upload said .bat file
3. The Powershell is a wrapper which creates a scheduled task so the .bat file can be run with TrustedInstaller privileges
    1. This deletes every security feature it can
    2. Also disables SmartScreen in Edge

Add the following to your Lab script to remove Defender from all systems (Change Get-LabVM to single hostname if required on single host)

```powershell
# Add Defender exclusion before uploading the script
Invoke-LabCommand -ComputerName (Get-LabVM) -ActivityName AddExclusions -ScriptBlock { Set-MpPreference -ExclusionPath "C:\Windows\Temp"; Set-MpPreference -ExclusionExtension "bat" }

# Upload Batch file to remove Windows Defender
Copy-LabFileItem -ComputerName (Get-LabVM) -Path $CustomScripts\RemoveWindowsDefender\RemoveWindowsDefender.bat -Destination "C:\Windows\Temp"

# Run the batch file as TrustedInstaller via Scheduled Task
Invoke-LabCommand -ComputerName (Get-LabVM) -ActivityName RemoveDefender -FileName 'Remove-WindowsDefender.ps1' -DependencyFolderPath $CustomScripts\RemoveWindowsDefender
```