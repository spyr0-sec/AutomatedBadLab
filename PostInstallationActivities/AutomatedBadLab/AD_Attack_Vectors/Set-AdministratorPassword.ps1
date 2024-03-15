Function Set-AdministratorPassword {
    [CmdletBinding()]
    param()

    Write-Host "  [+] Installing GPOs with encrypted passwords" -ForegroundColor Green

    $Administrator = Get-ADUser Administrator
    
    $Administrator | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString "Passw0rd!" -AsPlainText -Force)
    Write-Host "    [+] $Administrator password set to GPP encrypted value of Passw0rd!" -ForegroundColor Yellow
}
