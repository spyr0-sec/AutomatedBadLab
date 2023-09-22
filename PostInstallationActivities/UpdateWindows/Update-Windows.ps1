Write-Host "[+] Installing Nuget Package Provider.." -ForegroundColor Green
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Write-Host "[+] Installing PSWindowsUpdate Module.." -ForegroundColor Green
Install-Module PSWindowsUpdate -Force

# Install-WindowsUpdate does not work remotely. Mimic Invoke-WUJob by creating scheduled task
Write-Host "[+] Creating Windows Update Scheduled Task.." -ForegroundColor Green

# Enable Scheduled Task history logging for debugging
wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true

# Define the PowerShell command to run
$Command = "Import-Module PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -AutoReboot | Out-File C:\WindowsUpdate.log"

# Get the time a minute from now
$Time = (Get-Date).AddMinutes(1)

# Create a new scheduled task trigger to run once at the specified time
$Trigger = New-ScheduledTaskTrigger -Once -At $Time

# Run the scheduled task as SYSTEM
$User = "NT AUTHORITY\SYSTEM"

# Create a new action to run the PowerShell command
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""

# Register the scheduled task
Register-ScheduledTask -TaskName "PSWindowsUpdateTask" -Trigger $Trigger -Action $Action -User $User -RunLevel Highest -Force

# Output the result
Write-Host "[+] Windows will update at $Time. Please wait until the system reboots before proceeding.." -ForegroundColor Green
