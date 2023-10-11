Function Set-RandomACL($VulnUser, $VictimUser, $Right) {
    Set-ACE $VulnUser $VictimUser $Right
    Write-Host "    [+] $($VulnUser.DistinguishedName) -[$Right]-> $($VictimUser.DistinguishedName)" -ForegroundColor Yellow
}
