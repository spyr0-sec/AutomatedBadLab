Function Set-PasswordInDescription {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    Write-Log -Message "Putting roastable users password in their description field"

    # For each user, set a weak password
    foreach ($User in $VulnUsers) {

        $Password = New-Password

        # Reset their password to new value
        Set-ADAccountPassword -Identity $User -Reset -NewPassword (ConvertTo-SecureString $Password -AsPlainText -Force)

        # Write it in their description field in plain text
        Set-ADUser -Identity $User -Description "Just so I dont forget my password is: $Password"

        Write-Log -Message "$User has the password '$Password' in their description field" -Level "Informational"
    }

    # Pass back the vulnerable users to the main script
    return $VulnUsers
}