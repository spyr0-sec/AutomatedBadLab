[CmdletBinding()]
Param (
    [Parameter(Mandatory = $False)][string]$LocalUsername = "wsuser",
    [Parameter(Mandatory = $False)][string]$LocalPassword = "S3cureP@ssword"
)

# Logger function
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
    
    $LogMessage | Out-File -FilePath "C:\LPECookbook.log" -Append
}

# Download the cookbook 
Write-Log -Message "Downloading the cookbook"
Invoke-WebRequest -Uri "https://github.com/nickvourd/Windows-Local-Privilege-Escalation-Cookbook/archive/refs/heads/master.zip" -OutFile "C:\Windows-Local-Privilege-Escalation-Cookbook.zip"

# Unzip the cookbook
Write-Log -Message "Unzipping the cookbook"
Expand-Archive -Path "C:\Windows-Local-Privilege-Escalation-Cookbook.zip" -DestinationPath "C:\"

# Make password a secure string before passing to New-LocalUser
$SecurePassword = ConvertTo-SecureString -String $LocalPassword -AsPlainText -Force

$userParams = @{
    Name = $LocalUsername
    Password = $SecurePassword
    Description = "Low Privilege User"
    PasswordNeverExpires = $true
}

New-LocalUser @userParams

Write-Log -Message "Created low priv user '$LocalUsername' with password '$LocalPassword'"

# Add user to remote desktop users group
Write-Log -Message "Adding '$LocalUsername' to remote desktop users group"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $LocalUsername

# Run the setup scripts
Write-Log -Message "Running the setup scripts"

foreach ($Script in Get-ChildItem -Path "C:\Windows-Local-Privilege-Escalation-Cookbook-master\Lab-Setup-Scripts") {

    # AutomatedLab by design has plaintext passwords in unattend.xml and WinLogon
    $excludedScripts = @("AnswerFiles.ps1", "StoredCredentialsWinlogon.ps1")

    If ($excludedScripts -contains $Script.Name) {
        Write-Log -Message "Skipping $Script"
        Continue
    }

    Write-Log -Message "Running $Script"

    # Read in script contents to execute
    $ScriptContents = Get-Content -Path $Script.FullName -Raw

    # Replace output messages with Write-Log
    $MessageRegex = 'Write-Host "\s*(\[+\])?\s*'
    $ScriptContents = $ScriptContents -replace $MessageRegex, 'Write-Log -Message "'

    # Remove new line characters for tidy logging
    $ScriptContents = $ScriptContents -replace '`n', ''

    # Remove sleep commands
    $SleepRegex = 'Start-Sleep.*'
    $ScriptContents = $ScriptContents -replace $SleepRegex, ''

    # Remove any restart commands
    $RestartRegex = 'Restart-Computer.*'
    $ScriptContents = $ScriptContents -replace $RestartRegex, ''

    # Execute the script
    Invoke-Expression -Command $ScriptContents
}
