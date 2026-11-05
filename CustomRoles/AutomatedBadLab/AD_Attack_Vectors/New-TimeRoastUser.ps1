# https://github.com/OffsecDeer/TargetedTimeroast

Function New-TimeRoastUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    Write-Log -Message "Modifying a vulnerable user to be a computer object via UAC so it can be TimeRoasted"

    # Get random vulnerable user
    $VulnUser = $VulnUsers | Get-Random -ErrorAction SilentlyContinue

    # Modify the vulnerable user to be a computer object by changing the userAccountControl and samAccountName
    Set-ADUser -Identity $VulnUser -Replace @{
        userAccountControl = 4096;
        samAccountName = $VulnUser.SamAccountName + "$"
    }
}
