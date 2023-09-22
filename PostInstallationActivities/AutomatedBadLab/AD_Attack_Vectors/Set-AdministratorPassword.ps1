Function Set-AdministratorPassword {
    [CmdletBinding()]
    param()

    Write-Host "  [+] Installing GPOs with encrypted passwords" -ForegroundColor Green
    
    Get-ADUser Administrator | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString "Passw0rd!" -AsPlainText -Force)
    Write-Verbose "Reset Administrator password to GPP encrypted value of Passw0rd!"
}