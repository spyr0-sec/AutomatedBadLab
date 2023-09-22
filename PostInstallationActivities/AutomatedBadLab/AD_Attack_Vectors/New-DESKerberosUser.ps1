Function New-DESKerberosUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][string[]]$VulnUsers
    )

    Write-Host "  [+] Force DES Kerberos encryption on a vulnerable user" -ForegroundColor Green

    # Force DES Kerberos encryption for a weak user
    $DESUser = $VulnUsers | Get-Random
    Get-ADUser $DESUser | Set-ADAccountControl -UseDESKeyOnly $True
    Write-Verbose "Configured $DESUser to use DES Kerberos encryption"
}
