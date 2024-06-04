[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()][string]$Root = "C:\",
    [ValidateNotNullOrEmpty()][string]$Name = "BadShares"
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
    
    $LogMessage | Out-File -FilePath "C:\BadShares.log" -Append
}

Write-Log -Message "Downloading"
Invoke-WebRequest -Uri "https://github.com/techspence/BadShares/archive/refs/heads/main.zip" -OutFile "C:\Windows\Temp\BadShares.zip"

Write-Log -Message "Unzipping"
Expand-Archive -Path "C:\Windows\Temp\BadShares.zip" -DestinationPath "C:\Windows\Temp"


