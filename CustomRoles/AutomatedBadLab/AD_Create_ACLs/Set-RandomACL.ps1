Function Set-RandomACL($VulnUser, $VictimUser, $Right) {
    Set-ACE $VulnUser $VictimUser $Right
    Write-Log -Message "$VulnUser -[$Right]-> $VictimUser" -Level "Informational"
}
