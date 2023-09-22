# https://medium.com/techzap/dns-admin-privesc-in-active-directory-ad-windows-ecc7ed5a21a2

Function New-DNSAdmin {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][string[]]$VulnUsers
    )

    Write-Host "  [+] Adding a vulnerable user to the DNS Admins group" -ForegroundColor Green

    # Add a weak user to DNS admins group for domain privilege escalation
    $DNSAdmin = $VulnUsers | Get-Random
    Add-ADGroupMember -Identity DNSAdmins -Members $DNSAdmin
    Write-Verbose "Added $DNSAdmin to DNSAdmins group"
}
