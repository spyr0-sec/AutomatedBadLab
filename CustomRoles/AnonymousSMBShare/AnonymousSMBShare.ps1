[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)][string]$SMBPath,
    [Parameter(Mandatory = $True)][string]$SMBName,
    [Parameter(Mandatory = $True)][string]$SMBDescription
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
    
    $LogMessage | Out-File -FilePath "C:\SMBShare.log" -Append
}

Write-Log -Message "Sharing $SMBPath with name $SMBName"

# First check if the path exists
If (!(Test-Path $SMBPath)) {
    New-Item -ItemType Directory -Path $SMBPath
    Write-Log -Message "$SMBPath does not exist, creating" -Level "Warning"
}

# Configure registry to allow NULL access in SMB
Write-Log -Message "Configuring Registry to allow SMB Guest access"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "AllowInsecureGuestAuth" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RestrictAnonymous" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RestrictNullSessAccess" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "EveryoneIncludesAnonymous" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "NoAnonymous" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "NullSessionPipes" -Value "netlogon,samr,lsarpc" -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "NullSessionShares" -Value $SMBName -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "ForceGuest" -Value 1 -Force

# Active Guest account
Write-Log -Message "Activating Guest account"
Enable-LocalUser -Name "Guest"

# Configure SMB Share permissions
Write-Log -Message "Configuring SMB Share permissions"
$SMBAcl = Get-Acl $SMBPath
$SMBAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Guest","FullControl","Allow")
$SMBAcl.SetAccessRule($SMBAccessRule)
Set-Acl $SMBPath $SMBAcl

# Create SMB Share
Write-Log -Message "Creating SMB Share"
New-SmbShare -Name $SMBName -Path $SMBPath -Description $SMBDescription -FullAccess 'ANONYMOUS LOGON','Everyone'
