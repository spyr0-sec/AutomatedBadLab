Function Set-WritePermission($VulnUser, $VictimUser, $Attribute) {
    Set-ACE $VulnUser $VictimUser 'WriteProperty' $Attribute.Value
    Write-Host "    [+] $VulnUser -[$($Attribute.Key)]-> $VictimUser" -ForegroundColor Yellow
}
