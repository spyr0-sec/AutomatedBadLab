Function Set-WritePermission($VulnUser, $VictimUser, $Attribute) {
    Set-ACE $VulnUser $VictimUser 'WriteProperty' $Attribute.Value
    Write-Host "    [+] $($VulnUser.DistinguishedName) -[$($Attribute.Key)]-> $($VictimUser.DistinguishedName)" -ForegroundColor Yellow
}
