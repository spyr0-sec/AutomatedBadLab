Function Set-PasswordInDescription {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    Write-Host "  [+] Putting roastable users password in their description field" -ForegroundColor Green

    # For each user, set a weak password
    foreach ($User in $VulnUsers) {

        $Password = New-Password

        # Reset their password to new value
        Set-ADAccountPassword -Identity $User -Reset -NewPassword (ConvertTo-SecureString $Password -AsPlainText -Force)

        # Write it in their description field in plain text
        Set-ADUser -Identity $User -Description "Just so I dont forget my password is: $Password"

        Write-Host "    [+] $User has the password '$Password' in their description field" -ForegroundColor Yellow
    }

    # Pass back the vulnerable users to the main script
    return $VulnUsers
}