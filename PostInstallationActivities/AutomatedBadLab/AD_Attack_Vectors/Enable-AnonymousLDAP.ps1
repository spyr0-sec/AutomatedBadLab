# https://www.pwndefend.com/2021/02/25/how-to-enable-null-bind-on-ldap-with-windows-server-2019/

Function Enable-AnonymousLDAP {

    Write-Host "  [+] Allowing Anonymous read access to AD schema via LDAP" -ForegroundColor Green

    # Domain Distinguished Name
    $ADDN = (Get-ADDomain).DistinguishedName

    # First set DSHeuristics to 0000002 = Anonymous Bind
    Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$ADDN" -Replace @{DSHeuristics="0000002"}

    # RootDSE Path
    $RootDNPath = "AD:\$ADDN"

    # Get Anonymous Logon SID
    $anonymousId = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\ANONYMOUS LOGON")

    # Will also set the permissions to all child objects
    $secInheritanceAll = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All

    # Set the permissions
    $Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($anonymousId, "ReadProperty, GenericExecute", "Allow", $secInheritanceAll)
    $Acl = Get-Acl -Path $RootDNPath
    $Acl.AddAccessRule($Ace)
    Set-Acl -Path $RootDNPath -AclObject $Acl
}