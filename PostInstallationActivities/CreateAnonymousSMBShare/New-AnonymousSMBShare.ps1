Function New-AnonymousSMBShare {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][string]$SMBPath,
        [Parameter(Mandatory = $True)][string]$SMBName,
        [Parameter(Mandatory = $True)][string]$SMBDesc
    )

    Write-Verbose "  [+] Creating SMB Share $SMBName.." -Verbose

    # First check if the path exists
    If (!(Test-Path $SMBPath)) {
        New-Item -ItemType Directory -Path $SMBPath
        Write-Verbose "$SMBPath does not exist, creating"
    }

    # Configure registry to allow NULL access in SMB
    Write-Host "  [+] Configuring Registry to allow SMB Guest access.." -ForegroundColor Green
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "AllowInsecureGuestAuth" -Value 1 -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RestrictAnonymous" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "RestrictNullSessAccess" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "EveryoneIncludesAnonymous" -Value 1 -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "NoAnonymous" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "NullSessionPipes" -Value "netlogon,samr,lsarpc" -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "NullSessionShares" -Value $SMBName -Force

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "ForceGuest" -Value 1 -Force

    # Active Guest account
    Write-Host "  [+] Activating Guest account.." -ForegroundColor Green
    Enable-LocalUser -Name "Guest"

    # Configure SMB Share permissions
    Write-Host "  [+] Configuring SMB Share permissions.." -ForegroundColor Green
    $Acl = Get-Acl $SMBPath
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Guest","FullControl","Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl $SMBPath $Acl

    # Create SMB Share
    Write-Host "  [+] Creating SMB Share.." -ForegroundColor Green
    New-SmbShare -Name $SMBName -Path $SMBPath -Description $SMBDesc -FullAccess 'ANONYMOUS LOGON','Everyone'
}