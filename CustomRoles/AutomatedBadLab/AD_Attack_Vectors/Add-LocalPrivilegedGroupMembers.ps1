Function Add-LocalPrivilegedGroupMembers {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    # Get all computers in AD that do not have "AutomatedLab" in their description
    $NonABLComputers = Get-ADComputer -Filter * -Property Description | Where-Object {
        $_.Description -notlike "*AutomatedBadLab*"
    }

    foreach ($Computer in $NonABLComputers) {

        $VulnUser = ($VulnUsers | Get-Random -ErrorAction SilentlyContinue).SamAccountName

        Write-Log -Message "Adding $VulnUser to the local privileged groups on $($Computer.DNSHostName)"

        Invoke-Command -ComputerName $Computer.DNSHostName -ScriptBlock {
            $VulnUser = $using:VulnUser

            if (Get-LocalGroup -Name "Administrators" -ErrorAction SilentlyContinue) {
                # Add the vulnerable users the local privileged groups
                Add-LocalGroupMember -Group "Administrators" -Member $VulnUser
                Add-LocalGroupMember -Group "Remote Desktop Users" -Member $VulnUser
                Add-LocalGroupMember -Group "Remote Management Users" -Member $VulnUser
            } else {
                # If Local Admins group does not exist, then we are on a DC so use RODC as an attack vector instead
                Add-LocalGroupMember -Group "Allowed RODC Password Replication Group" -Member $VulnUser
            }
        }
    }
}
