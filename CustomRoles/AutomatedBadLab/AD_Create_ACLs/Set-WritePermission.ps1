Function Set-WritePermission($VulnUser, $VictimUser, $Attribute) {
    Set-ACE $VulnUser $VictimUser 'WriteProperty' $Attribute.Value
    Write-Log -Message "$VulnUser -[$($Attribute.Key)]-> $VictimUser" -Level "Informational"
}
