Function Set-PasswordInDescription {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][string[]]$VulnUsers
    )

    Write-Host "  [+] Putting roastable users password in their description field" -ForegroundColor Green

    # For each user, set a weak password
    foreach ($User in $VulnUsers) {

        $Password = New-Password

        # Reset their password to new value
        Get-ADUser $User | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString $Password -AsPlainText -Force)

        # Write it in their description field in plain text
        Get-ADUser $User | Set-ADUser -Description "Just so I dont forget my password is: $Password"

        Write-Verbose "$User has the password '$Password' in their description field"   
    }

    # Pass back the vulnerable users to the main script
    return $VulnUsers
}