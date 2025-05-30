Function New-SystemRegKey {

    Write-Log -Message "Adding Admin password to Domain User readable SYSTEM user Registry Hive"

    $RegPath = "Registry::HKEY_USERS\S-1-5-18\Software\Microsoft\Installer\ACME Corp"

    New-Item -Path $RegPath -Force

    Set-ItemProperty -Path $RegPath -Name "InstallerUsername" -Value "Administrator"
    Set-ItemProperty -Path $RegPath -Name "InstallerPassword" -Value "Passw0rd!"

    # Enable Remote Registry Service to make it accessible
    Set-Service -Name RemoteRegistry -StartupType Automatic
    Start-Service -Name RemoteRegistry
}
