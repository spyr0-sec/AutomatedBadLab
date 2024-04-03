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
    
    $LogMessage | Out-File -FilePath "C:\WindowsDefenderRemoval.log" -Append
}

Add-MpPreference -ExclusionPath "C:\Windows\Temp"

Write-Log -Message "Created AV exclusions for the files to be uploaded."

Invoke-WebRequest -Uri "https://github.com/ionuttbara/windows-defender-remover/archive/refs/heads/main.zip" -OutFile "C:\Windows\Temp\DefenderRemover.zip"

Expand-Archive -Path "C:\Windows\Temp\DefenderRemover.zip" -DestinationPath "C:\Windows\Temp"

Write-Log -Message "Downloaded and extracted the Windows Defender Remover script."

# Define the path to your original batch file
$batchFilePath = "C:\Windows\Temp\windows-defender-remover-main\Script_Run.bat"

# Enable Scheduled Task history logging for debugging
wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true

Write-Log -Message "Creating Windows Defender Removal Scheduled Task" 

# Create the scheduled task action
$Action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $batchFilePath Y"

# Get the time a minute from now
$Time = (Get-Date).AddMinutes(1)

# Create a new scheduled task trigger to run once at the specified time
$Trigger = New-ScheduledTaskTrigger -Once -At $Time

# Run the scheduled task as SYSTEM
$User = "NT AUTHORITY\SYSTEM"

# Register the scheduled task
Register-ScheduledTask -TaskName "RemoveWindowsDefender" -Trigger $Trigger -Action $Action -User $User -RunLevel Highest -Force

# Output the result
Write-Log -Message "Windows Defender will be removed at $Time. Please wait until the system reboots before proceeding" 
