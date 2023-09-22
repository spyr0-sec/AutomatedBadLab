Function New-ReversablePasswordUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][string[]]$VulnUsers
    )

    Write-Host "  [+] Force reversable password encryption on a vulnerable user" -ForegroundColor Green

    # Force DES Kerberos encryption for a weak user
    $RevEncUser = $VulnUsers | Get-Random
    Get-ADUser $RevEncUser | Set-ADAccountControl -AllowReversiblePasswordEncryption $True
    Write-Verbose "Configured $RevEncUser to use reversable password encryption"
}
