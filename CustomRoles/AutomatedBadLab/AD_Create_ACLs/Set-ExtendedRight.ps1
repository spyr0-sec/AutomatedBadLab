Function Set-ExtendedRight($VulnUser, $VictimUser, $ExtendedRight) {
    Set-ACE $VulnUser $VictimUser 'ExtendedRight' $ExtendedRight.Value
    Write-Log -Message "$VulnUser -[$($ExtendedRight.Key)]-> $VictimUser" -Level "Informational"
}
