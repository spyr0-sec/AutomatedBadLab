Function New-ReversablePasswordUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    Write-Log -Message "Force reversable password encryption on a vulnerable user"

    # Force DES Kerberos encryption for a weak user
    $RevEncUser = $VulnUsers | Get-Random -ErrorAction SilentlyContinue
    Set-ADAccountControl -Identity $RevEncUser -AllowReversiblePasswordEncryption $True
    Write-Log -Message "$RevEncUser configured to use reversable password encryption" -Level "Informational"
}
