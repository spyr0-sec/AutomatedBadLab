$LogFilePath = "C:\WindowsUpdate.log"

Function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [ValidateSet("Default", "Informational", "Warning")]
        [string]$Level = "Default"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    switch ($Level) {
        "Default"       { $LogMessage = "$Timestamp - [+] $Message" }
        "Informational" { $LogMessage = "$Timestamp -   [+] $Message" }
        "Warning"       { $LogMessage = "$Timestamp -   [!] $Message" }
    }
    
    $LogMessage | Out-File -FilePath "C:\WindowsUpdate.log" -Append
}

Write-Log -Message "Installing Nuget Package Provider"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Write-Log -Message "Installing PSWindowsUpdate Module" 
Install-Module PSWindowsUpdate -Force

# Install-WindowsUpdate does not work remotely. Mimic Invoke-WUJob by creating scheduled task
Write-Log -Message "Creating Windows Update Scheduled Task" 

# Enable Scheduled Task history logging for debugging
wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true

# Define the PowerShell command to run
$Command = "Import-Module PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -AutoReboot | Out-File -FilePath $LogFilePath -Append"

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
Write-Log -Message "Windows will update at $Time. Please wait until the system reboots before proceeding" 
