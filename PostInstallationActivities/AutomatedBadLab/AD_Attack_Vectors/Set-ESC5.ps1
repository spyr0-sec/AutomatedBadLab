Function Set-ESC5 {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    Write-Host "  [+] Providing a vulnerable user danagerous rights over the CA Computer Object (ESC5)" -ForegroundColor Green

    # Provide a vulnerable user GenericAll over the CA
    $CAUser = $VulnUsers | Get-Random

    # Get CA Computer Object
    $CAComputer = Get-ADComputer -Identity (Get-ADGroupMember -Identity "Cert Publishers" | Where-Object objectClass -EQ computer).name

    # Give GenericAll over the CA Computer Object
    Set-RandomACL $CAUser $CAComputer 'GenericAll'
}