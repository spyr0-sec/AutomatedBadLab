Function New-Owner {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][string[]]$VulnUsers
    )

    Write-Host "  [+] Providing a vulnerable user ownership over a user and computer object" -ForegroundColor Green

    # Get random vulnerable user
    $VulnUser = Get-ADUser -Identity ($VulnUsers | Get-Random)

    # Get a random victim user
    $OwnerVictimUser = Get-ADUser -Filter {Description -like '*AutomatedBadLab*'} -Properties Description | Get-Random -Count 1

    # Get the ACL for the victim user
    $OwnerVictimUserACL = Get-Acl -Path "AD:\$($OwnerVictimUser.DistinguishedName)"

    Write-Host "    [+] $($VulnUser.SamAccountName) owns $($OwnerVictimUser.DistinguishedName)" -ForegroundColor Yellow

    # Set the owner of the victim user to the vulnerable user
    $OwnerVictimUserACL.SetOwner([System.Security.Principal.NTAccount]"$((Get-ADDomain).NetBIOSName)\$($VulnUser.samAccountName)")

    # Now do the same for a computer object
    $OwnerVictimComputer = Get-ADComputer -Filter {Description -like '*AutomatedBadLab*'} -Properties Description | Get-Random -Count 1

    $OwnerVictimComputerACL = Get-Acl -Path "AD:\$($OwnerVictimComputer.DistinguishedName)"

    $OwnerVictimComputerACL.SetOwner([System.Security.Principal.NTAccount]"$((Get-ADDomain).NetBIOSName)\$($VulnUser.samAccountName)")

    Write-Host "    [+] $($VulnUser.SamAccountName) owns $($OwnerVictimComputer.DistinguishedName)" -ForegroundColor Yellow

}
