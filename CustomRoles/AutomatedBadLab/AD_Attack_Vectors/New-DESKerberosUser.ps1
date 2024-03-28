Function New-DESKerberosUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    Write-Log -Message "Force DES Kerberos encryption on a vulnerable user"

    # Force DES Kerberos encryption for a weak user
    $DESUser = $VulnUsers | Get-Random
    Set-ADAccountControl -Identity $DESUser -UseDESKeyOnly $True
    Write-Log -Message "$DESUser configured to use DES Kerberos encryption" -Level "Informational"
}
