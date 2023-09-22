Function Set-ACE($VulnUser, $VictimUser, $Right, $GuidValue = $null) {
    
    # Bind to the victim
    $VictimDN = ($VictimUser).DistinguishedName
    $Victim = [ADSI]"LDAP://$VictimDN"

    # Create a new ACE
    if ($GuidValue) {
        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($VulnUser.SID, $Right, "Allow", [System.Guid]::Parse($GuidValue))
    } else {
        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($VulnUser.SID, $Right, "Allow")
    }

    # Apply the ACE and Commit the changes
    $Victim.ObjectSecurity.AddAccessRule($ace)
    $Victim.CommitChanges()
}
