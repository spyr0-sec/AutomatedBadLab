Function Set-AdministratorPassword {

    [CmdletBinding()]
    param()

    Write-Log -Message "Installing GPOs with encrypted passwords"

    $Administrator = Get-ADUser Administrator
    
    $Administrator | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString "Passw0rd!" -AsPlainText -Force)
    Write-Log -Message "$Administrator password set to GPP encrypted value of Passw0rd!" -Level "Informational"
}
