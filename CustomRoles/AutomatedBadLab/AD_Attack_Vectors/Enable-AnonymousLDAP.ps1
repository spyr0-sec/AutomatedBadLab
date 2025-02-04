# https://www.pwndefend.com/2021/02/25/how-to-enable-null-bind-on-ldap-with-windows-server-2019/

Function Enable-AnonymousLDAP {

    Write-Log -Message "Allowing Anonymous read access to AD schema via LDAP"

    # Domain Distinguished Name
    $ADDN = (Get-ADDomain).DistinguishedName

    # RootDSE Path
    $RootDNPath = "AD:\$ADDN"

    # Get Anonymous Logon SID
    $anonymousId = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\ANONYMOUS LOGON")

    # Set the rights and type
    $aclRights = [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::GenericExecute
    $allowType = [System.Security.AccessControl.AccessControlType]::Allow

    # Will also set the permissions to all child objects
    $secInheritanceAll = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All

    # Set the permissions
    $Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($anonymousId, $aclRights, $allowType, $secInheritanceAll)
    $Acl = Get-Acl -Path $RootDNPath
    $Acl.AddAccessRule($Ace)
    Set-Acl -Path $RootDNPath -AclObject $Acl

    # Configure DSHeuristics
    $DsPath = "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$ADDN"
    Set-ADObject -Identity $DsPath -Replace @{dSHeuristics = "0000002"}
}
