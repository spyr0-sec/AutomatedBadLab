
Function Set-BlankPassword {

    # Get a random AD user
    $VulnUser = Get-ADUser -Filter * | Get-Random

    # Modify the user to permit blank password
    Set-ADAccountControl $VulnUser -PasswordNotRequired $true

    # Set the password to blank using ADSI (ConvertTo-SecureString does not allow blank strings)
    $VulnUserADSI = [ADSI]"LDAP://$($VulnUser.DistinguishedName)"
    $VulnUserADSI.Invoke("SetPassword", "")
    $VulnUserADSI.SetInfo()

    Write-Log -Message "$VulnUser has a blank password" -Level "Informational"

    # Pass back the vulnerable users to the main script
    return $VulnUser
}
