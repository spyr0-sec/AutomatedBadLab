Function Set-WritePermission($VulnUser, $VictimUser, $Attribute) {
    Set-ACE $VulnUser $VictimUser 'WriteProperty' $Attribute.Value
    Write-Verbose "$($VulnUser.DistinguishedName) -[$($Attribute.Key)]-> $($VictimUser.DistinguishedName)"
}
