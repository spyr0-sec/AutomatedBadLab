Function Set-ExtendedRight($VulnUser, $VictimUser, $ExtendedRight) {
    Set-ACE $VulnUser $VictimUser 'ExtendedRight' $ExtendedRight.Value
    Write-Verbose "$($VulnUser.DistinguishedName) -[$($ExtendedRight.Key)]-> $($VictimUser.DistinguishedName)"
}
