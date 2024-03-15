Function Set-ExtendedRight($VulnUser, $VictimUser, $ExtendedRight) {
    Set-ACE $VulnUser $VictimUser 'ExtendedRight' $ExtendedRight.Value
    Write-Host "    [+] $VulnUser -[$($ExtendedRight.Key)]-> $VictimUser" -ForegroundColor Yellow
}
