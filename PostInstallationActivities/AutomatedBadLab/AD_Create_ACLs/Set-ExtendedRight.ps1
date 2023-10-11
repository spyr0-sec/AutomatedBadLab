Function Set-ExtendedRight($VulnUser, $VictimUser, $ExtendedRight) {
    Set-ACE $VulnUser $VictimUser 'ExtendedRight' $ExtendedRight.Value
    Write-Host "    [+] $($VulnUser.DistinguishedName) -[$($ExtendedRight.Key)]-> $($VictimUser.DistinguishedName)" -ForegroundColor Yellow
}
