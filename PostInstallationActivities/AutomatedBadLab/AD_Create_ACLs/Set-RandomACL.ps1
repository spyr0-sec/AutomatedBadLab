Function Set-RandomACL($VulnUser, $VictimUser, $Right) {
    Set-ACE $VulnUser $VictimUser $Right
    Write-Host "    [+] $VulnUser -[$Right]-> $VictimUser" -ForegroundColor Yellow
}
