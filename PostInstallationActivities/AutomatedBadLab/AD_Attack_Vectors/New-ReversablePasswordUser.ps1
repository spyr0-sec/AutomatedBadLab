Function New-ReversablePasswordUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    Write-Host "  [+] Force reversable password encryption on a vulnerable user" -ForegroundColor Green

    # Force DES Kerberos encryption for a weak user
    $RevEncUser = $VulnUsers | Get-Random
    Set-ADAccountControl -Identity $RevEncUser -AllowReversiblePasswordEncryption $True
    Write-Host "    [+] $RevEncUser configured to use reversable password encryption" -ForegroundColor Yellow
}
