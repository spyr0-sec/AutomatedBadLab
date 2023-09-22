Function Set-RandomACL($VulnUser, $VictimUser, $Right) {
    Set-ACE $VulnUser $VictimUser $Right
    Write-Verbose "$($VulnUser.DistinguishedName) -[$Right]-> $($VictimUser.DistinguishedName)"
}
