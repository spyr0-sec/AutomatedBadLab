Function New-RBCDUser {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    Write-Log -Message "Providing a vulnerable user ability to perform RBCD attacks on a user and computer object"

    # Get random vulnerable user
    $VulnUser = $VulnUsers | Get-Random -ErrorAction SilentlyContinue

    # Get the GUID for the msDS-AllowedToActOnBehalfOfOtherIdentity extended right
    $ACLMap = @{
        "msDS-AllowedToActOnBehalfOfOtherIdentity" = "3f78c3e5-f79a-46bd-a0b8-9d18116ddc79"
    }

    # Get a random AutomatedBadLab computer
    $RBCDVictimComputer = Get-ADComputer -Filter {Description -like '*AutomatedBadLab*'} -Properties Description | Get-Random -Count 1

    # Provide the User with the ability to perform Resource Based Constrained Delegation on a computer object
    Set-ExtendedRight $VulnUser $RBCDVictimComputer ($ACLMap.GetEnumerator() | Get-Random)

    # Get a random AutomatedBadLab user which has a Service Principal Name
    $RBCDVictimUser = Get-ADUser -Filter {(Description -like '*AutomatedBadLab*') -and (ServicePrincipalName -like '*')} -Properties Description, ServicePrincipalName | Get-Random -Count 1

    # Then provide the User with the ability to perform Resource Based Constrained Delegation on a user object
    Set-ExtendedRight $VulnUser $RBCDVictimUser ($ACLMap.GetEnumerator() | Get-Random)
}
