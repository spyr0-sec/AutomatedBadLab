Function New-DESKerberosUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    Write-Host "  [+] Force DES Kerberos encryption on a vulnerable user" -ForegroundColor Green

    # Force DES Kerberos encryption for a weak user
    $DESUser = $VulnUsers | Get-Random
    Set-ADAccountControl -Identity $DESUser -UseDESKeyOnly $True
    Write-Host "    [+] $DESUser configured to use DES Kerberos encryption" -ForegroundColor Yellow
}
