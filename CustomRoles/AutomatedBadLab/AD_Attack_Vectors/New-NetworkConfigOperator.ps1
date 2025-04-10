# https://birkep.github.io/posts/Windows-LPE/

Function New-NetworkConfigOperator {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    Write-Log -Message "Adding a vulnerable user to the Network Configuration Operators group"

    # Add a weak user to DNS admins group for domain privilege escalation
    $NetworkOperator = $VulnUsers | Get-Random -ErrorAction SilentlyContinue
    Add-ADGroupMember -Identity "Network Configuration Operators" -Members $NetworkOperator
    Write-Log -Message "$NetworkOperator member of Network Configuration Operators group" -Level "Informational"
}
