Function New-DCSyncUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    Write-Log -Message "Providing a vulnerable user Replication Extended Rights to perform a DCSync"

    # Provide a vulnerable user Replication Extended Rights
    $DCSyncUser = $VulnUsers | Get-Random

    # Define the rights
    $DCSyncMap = @{
        "DS-Replication-Get-Changes" = "1131f6aa-9c07-11d1-f79f-00c04fc2dcd2"
        "DS-Replication-Get-Changes-All" = "1131f6ad-9c07-11d1-f79f-00c04fc2dcd2"
    }

    # Provide the user with both extended rights to perform a DCSync
    foreach ($DCRight in $DCSyncMap.GetEnumerator()) {
        Set-ExtendedRight $DCSyncUser $(Get-ADDomain) $DCRight
    }
}
