# https://gist.github.com/Diagg/c3ca51c8a3d9d7665fbaf4252b1346ef

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

Write-Log -Message "Creating Windows Defender Removal Scheduled Task"

# Enable Scheduled Task history logging for debugging
wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true

# Create the scheduled task action
$batFilePath = "C:\Windows\Temp\RemoveWindowsDefender.bat"
$Action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $batFilePath"

# Create an object containing the administrator group principal
$Principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators"

# Register the scheduled task
Register-ScheduledTask -TaskName "RemoveWindowsDefender" -Action $Action -Principal $Principal

# Register-ScheduledTask doesn't support running as TrustedInstaller, so we need to use the COM object
$svc = New-Object -ComObject 'Schedule.Service'
$svc.Connect()

# Run the created scheduled task as TrustedInstaller
$user = 'NT SERVICE\TrustedInstaller'
$folder = $svc.GetFolder('\')
$task = $folder.GetTask('RemoveWindowsDefender')

# Start Task
$task.RunEx($null, 0, 0, $user)

Write-Log -Message ".bat script executed. Waiting for reboot"