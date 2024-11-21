Function Set-ESC5 {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    Write-Log -Message "Providing a vulnerable user danagerous rights over the CA Computer Object (ESC5)"

    # Provide a vulnerable user GenericAll over the CA
    $CAUser = $VulnUsers | Get-Random -ErrorAction SilentlyContinue

    # Get CA Computer Object
    $CAComputer = Get-ADComputer -Identity (Get-ADGroupMember -Identity "Cert Publishers" | Where-Object objectClass -EQ computer).name

    # Give GenericAll over the CA Computer Object
    Set-RandomACL $CAUser $CAComputer 'GenericAll'
}