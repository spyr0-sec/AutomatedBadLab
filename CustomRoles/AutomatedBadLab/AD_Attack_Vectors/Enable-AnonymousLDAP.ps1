# https://www.pwndefend.com/2021/02/25/how-to-enable-null-bind-on-ldap-with-windows-server-2019/

Function Enable-AnonymousLDAP {

    Write-Log -Message "Allowing Anonymous read access to AD schema via LDAP"

    # Domain Distinguished Name
    $DomainDN = (Get-ADDomain).DistinguishedName

    # RootDSE Path
    $RootDSE = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$DomainDN")

    # Get Anonymous Logon SID
    $anonymousSID = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-7')

    # Set the rights and type
    $aclRights = [System.DirectoryServices.ActiveDirectoryRights]::GenericRead
    $allowType = [System.Security.AccessControl.AccessControlType]::Allow

    # Will also set the permissions to all child objects
    $secInheritanceAll = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All

    # Add the new ACE to the ACL
    $Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($anonymousSID, $aclRights, $allowType, $secInheritanceAll)
    $Acl = $RootDSE.ObjectSecurity
    $Acl.AddAccessRule($Ace)

    $RootDSE.ObjectSecurity = $Acl
    $RootDSE.CommitChanges()

    # Configure DSHeuristics
    $DsPath = "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$ADDN"
    Set-ADObject -Identity $DsPath -Replace @{dSHeuristics = "0000002"}
}
