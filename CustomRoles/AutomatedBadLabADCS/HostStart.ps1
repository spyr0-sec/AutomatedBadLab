# References:
# https://posts.specterops.io/certified-pre-owned-d95910965cd2
# https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-crtd/ec71fd43-61c2-407b-83c9-b52272dec8a1 

# Vulnerabilities:
# (1) Enterpise CA Enrollment Rights - Attacker is permitted to enroll (request) certificates from the CA
#       Default config
# (2) Managers Approval - When msPKI-Enrollment-Flag is *not* set to msPKI-Enrollment-Flag (2)
# (3) No Authorised Signatures - Does not require authorised signature 
#       Get-ADObject "$CertDN" -Properties * | Set-ADObject -Replace @{'msPKI-RA-Signature' = 0}
# (4) Enrollment Rights - Attacker has the enroll Extended Right permission over the Certificate Template AD Object
#       New-LabCATemplate -SamAccountName "Domain Users"
# (5) Client Authentication - When msPKI-Certificate-Application-Policy & pKIExtendedKeyUsage is set to Client Authentication (1.3.6.1.5.5.7.3.2)
#       New-LabCATemplate -ApplicationPolicy 'Client Authentication'  
#       Get-ADObject "$CertDN" -Properties * | Set-ADObject -Replace @{'pKIExtendedKeyUsage' = '1.3.6.1.5.5.7.3.2'}
# (6) Enrollee Supplies Subject - When attribute msPKI-Certificate-Name-Flag is set to CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT (1)
#       Get-ADObject "$CertDN" -Properties * | Set-ADObject -Replace @{'msPKI-Certificate-Name-Flag' = 1}
#       TODO - New-LabCATemplate -NameFlags 'EnrolleeSuppliesSubject'
# (7) Any Purpose - When msPKI-Certificate-Application-Policy & pKIExtendedKeyUsage  is set to Any Purpose (2.5.29.37.0)
#       New-LabCATemplate -ApplicationPolicy 'ANY_APPLICATION_POLICY'
#       Get-ADObject "$CertDN" -Properties * | Set-ADObject -Replace @{'pKIExtendedKeyUsage' = '2.5.29.37.0'}
# (8) Allows for principals to request other certificate templates on behalf of other users
#       Get-ADObject "$CertDN" -Properties * | Set-ADObject -Add @{'msPKI-RA-Application-Policies' = '1.3.6.1.4.1.311.20.2.1'}
# (9) Attackers having GenericAll / WriteDacl over the CA AD Object
# (10) EDITF_ATTRIBUTESUBJECTALTNAME2 configured to permit User Supplied SANs 
# (11) Version 1 Templates permit User Supplied msPKI-Certificate-Application-Policy

# Import Lab
Import-Lab -Name $data.Name -NoValidation -NoDisplay

# CA machine object to create the Certificate Templates on
$CertificationAuthority = Get-LabVM -Role CaRoot

# DC machine object to conduct Certificate Template AD object manipulation
$DomainController = (Get-LabVM -Role RootDC | Where-Object { $_.DomainName -eq $CertificationAuthority.DomainName })

#--------------------------------------------------------------------------------------------------------------------
# ESC1 - Combination of vulns (1) & (2) & (3) & (4) & (5) & (6)
New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC1" -DisplayName "ESC1" -SourceTemplateName "User" `
                    -SamAccountName "Domain Users" -ComputerName $CertificationAuthority

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Configuring Client Authentication application policy & user supplied SANs" -ScriptBlock {
    Get-ADObject "CN=ESC1,CN=Certificate Templates,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)" -Properties * |
    Set-ADObject -Replace @{
        'msPKI-Certificate-Name-Flag' = 1
        'pKIExtendedKeyUsage' = '1.3.6.1.5.5.7.3.2'
    }
}

#--------------------------------------------------------------------------------------------------------------------
# ESC2 - Combination of vulns (1) & (2) & (3) & (4) & (5) & (7)
New-LabCATemplate -ApplicationPolicy 'ANY_APPLICATION_POLICY' -TemplateName "ESC2" -DisplayName "ESC2" -SourceTemplateName "User" `
                    -SamAccountName "Domain Users" -ComputerName $CertificationAuthority

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Configuring Any Purpose application policy & user supplied SANs" -ScriptBlock {
    Get-ADObject "CN=ESC2,CN=Certificate Templates,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)" -Properties * |
    Set-ADObject -Replace @{
        'msPKI-Certificate-Name-Flag' = 1
        'pKIExtendedKeyUsage' = '2.5.29.37.0'
    }
}

#--------------------------------------------------------------------------------------------------------------------
# ESC3 - Combination of vulns (1) & (2) & (3) & (7) & (8)
New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC3" -DisplayName "ESC3" -SourceTemplateName "User" `
                    -SamAccountName "Domain Users" -ComputerName $CertificationAuthority

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Configuring user supplied SANs" -ScriptBlock {
    Get-ADObject "CN=ESC3,CN=Certificate Templates,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)" -Properties * | 
    Set-ADObject -Add @{
        'msPKI-RA-Application-Policies' = '1.3.6.1.4.1.311.20.2.1'
    }
}

#--------------------------------------------------------------------------------------------------------------------
# ESC4 - (9)
New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC4" -DisplayName "ESC4" -SourceTemplateName "User" `
                    -SamAccountName "Enterprise Admins" -ComputerName $CertificationAuthority

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Providing GenericAll permission to Authenticated Users to ESC4 CA AD Object" -ScriptBlock {
    $AuthenticatedUsers = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-11')
    $GenericAll = [System.DirectoryServices.ActiveDirectoryRights]::GenericAll
    $Allow = [System.Security.AccessControl.AccessControlType]::Allow

    $ESC4Obj = "AD:\CN=ESC4,CN=Certificate Templates,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)"

    $ESC4ACL = Get-Acl $ESC4Obj
    $ESC4AccessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $AuthenticatedUsers,$GenericAll,$Allow
    $ESC4ACL.AddAccessRule($ESC4AccessRule)
    Set-Acl $ESC4Obj -AclObject $ESC4ACL
}

#--------------------------------------------------------------------------------------------------------------------
# ESC5 - GenericAll over the CA Computer Object
# ATTACK vector in AutomatedBadLab

#--------------------------------------------------------------------------------------------------------------------
# ESC6 - Configure EDITF_ATTRIBUTESUBJECTALTNAME2 (Set by default on CAs < May 2022)
Invoke-LabCommand -ComputerName $CertificationAuthority -ActivityName "Configure EDITF_ATTRIBUTESUBJECTALTNAME2" -ScriptBlock {
    certutil -config \ -setreg policy\EditFlags +EDITF_ATTRIBUTESUBJECTALTNAME2
    Restart-Service -Name 'certsvc' -Force 
}

#--------------------------------------------------------------------------------------------------------------------
# ESC7 - ManageCA / ManageCertificates Permissions
# ATTACK vector in AutomatedBadLab

#--------------------------------------------------------------------------------------------------------------------
# ESC8 - Vulnerable IIS web enrollment
Invoke-LabCommand -ComputerName $CertificationAuthority -ActivityName "Configure Certificate Enrollment Web Service" -ScriptBlock {
    Install-WindowsFeature -Name ADCS-Web-Enrollment
    Install-AdcsWebEnrollment -Force
}

#--------------------------------------------------------------------------------------------------------------------
# https://research.ifcr.dk/certipy-4-0-esc9-esc10-bloodhound-gui-new-authentication-and-request-methods-and-more-7237d88061f7
# ESC9 / 10a - StrongCertificateBinding
Invoke-LabCommand -ComputerName $DomainController -ActivityName "Disable StrongCertificateBinding" -ScriptBlock {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Kdc" -Name "StrongCertificateBinding" -Value 0 -Type DWord
}

New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC9" -DisplayName "ESC9" -SourceTemplateName "User" `
                    -SamAccountName "Domain Users" -EnrollmentFlags IncludeSymmetricAlgorithms -ComputerName $CertificationAuthority -Version 2

# New-LabCATemplate doesn't support CT_FLAG_NO_SECURITY_EXTENSION so need to patch msPKI-Enrollment-Flag manually
Invoke-LabCommand -ComputerName $DomainController -ActivityName "Add CT_FLAG_NO_SECURITY_EXTENSION to ESC9 Template" -ScriptBlock {
    # Add CT_FLAG_NO_SECURITY_EXTENSION flag to Certificate Template
    Get-ADObject "CN=ESC9,CN=Certificate Templates,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)" -Properties msPKI-Enrollment-Flag |
    Set-ADObject -Replace @{
        'msPKI-Enrollment-Flag' = 0x00080000
    }
}

#--------------------------------------------------------------------------------------------------------------------
# ESC10b - CertificateMappingMethods
New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC10b" -DisplayName "ESC10b" -SourceTemplateName "User" `
                    -SamAccountName "Domain Users" -ComputerName $CertificationAuthority -Version 2

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Introduce Weak CertificateMappingMethods" -ScriptBlock {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel" -Name "CertificateMappingMethods" -Value 0x0004 -Type DWord
}                  

#--------------------------------------------------------------------------------------------------------------------
# ESC13 - OID Group Link
New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC13" -DisplayName "ESC13" -SourceTemplateName "User" `
                    -SamAccountName "Domain Users" -ComputerName $CertificationAuthority -Version 2

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Group Link OID to Users DN" -ScriptBlock {
    $PKSContainer = "CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)"

    # Create an empty universal AD group
    New-ADGroup -Name "ESC13" -GroupScope Universal -Path "CN=Users,$((Get-ADRootDSE).defaultNamingContext)"
    $UniversalGroup = Get-ADGroup -Identity "ESC13"       

    # Vulnerable OID Attributes
    $OIDName = "10330615.D778637A99097DF4BED6C54BF449A9E6"
    $CertTemplateOID = "1.3.6.1.4.1.311.21.8.9522117.16246852.1590176.9773407.13761117.29.6161680.10330615"
    $OIDAttributes = @{
        Name = $OIDName
        DisplayName = "ESC13"
        'msPKI-Cert-Template-OID' = $CertTemplateOID
        flags = 2
        'msDS-OIDToGroupLink' = $UniversalGroup.DistinguishedName
    }

    # Create the OID
    New-ADObject -Name $OIDName -Type msPKI-Enterprise-Oid -Path "CN=OID,$PKSContainer" -OtherAttributes $OIDAttributes

    # Add Assurance Issuance Policy to Certificate Template
    $ESC13CertTemplate = Get-ADObject "CN=ESC13,CN=Certificate Templates,$PKSContainer" -Properties *

    Set-ADObject -Identity $ESC13CertTemplate.DistinguishedName -Replace @{
        flags = 131642
        'msPKI-Enrollment-Flag' = 32
        'msPKI-Private-Key-Flag' = 16842752
        'msPKI-RA-Signature' = 1
    }

    Set-ADObject -Identity $ESC13CertTemplate.DistinguishedName -Replace @{
        'msPKI-Certificate-Policy' = $CertTemplateOID
        'msPKI-RA-Policies' = $CertTemplateOID
    }

    # Provide DCSync rights to the group to make it exploitable
    $Domain = [ADSI]"LDAP://$(Get-ADDomain)"

    # Define the rights
    $DCSyncMap = @{
        "DS-Replication-Get-Changes" = "1131f6aa-9c07-11d1-f79f-00c04fc2dcd2"
        "DS-Replication-Get-Changes-All" = "1131f6ad-9c07-11d1-f79f-00c04fc2dcd2"
    }

    # Apply the DCSync ACEs and commit the changes
    foreach ($DCRight in $DCSyncMap.GetEnumerator()) { 
        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($UniversalGroup.SID, "ExtendedRight", "Allow", [System.Guid]::Parse($DCRight.Value))
        $Domain.ObjectSecurity.AddAccessRule($ace)
        $Domain.CommitChanges()
    }
}

#--------------------------------------------------------------------------------------------------------------------
# ESC15 - Combination of vulns (1) & (2) & (3) & (4) & (6) & (11)
New-LabCATemplate -TemplateName "ESC15" -DisplayName "ESC15" -SourceTemplateName "User" `
                    -SamAccountName "Domain Users" -ComputerName $CertificationAuthority -Version 1

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Removing Application Policies & adding user supplied SANs" -ScriptBlock {
    Get-ADObject "CN=ESC15,CN=Certificate Templates,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)" -Properties * | 
    Set-ADObject -Clear 'msPKI-Certificate-Application-Policy' -Replace @{
        'msPKI-Certificate-Name-Flag' = 1
    }
}                    

#--------------------------------------------------------------------------------------------------------------------
# Configure LDAPS for GMSA Attacks
New-LabCATemplate -ApplicationPolicy 'Server Authentication' -TemplateName "LDAPS" -DisplayName "LDAPS" -SourceTemplateName "WebServer" `
                    -SamAccountName "Domain Controllers" -ComputerName $CertificationAuthority -Version 2

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Configure StartTLS for LDAP" -ScriptBlock {
    # Request a certificate from the new LDAPS template
    $LDAPSCert = Get-Certificate -Template "LDAPS" -Url ldap: -SubjectName "CN=$((Get-ADDomainController).Hostname)" -CertStoreLocation Cert:\LocalMachine\My

    # Install Template
    $LDAPSCertThumbPrint = $LDAPSCert.Certificate.Thumbprint
    $LDAPSCertSourcePath = "HKLM:\SOFTWARE\Microsoft\SystemCertificates\MY\Certificates\$LDAPSCertThumbPrint"
    $LDAPSCertDestPath = "HKLM:\SOFTWARE\Microsoft\Cryptography\Services\NTDS\SystemCertificates\My\Certificates"
    
    New-Item -Path $LDAPSCertDestPath -Force
    Copy-Item -Path $LDAPSCertSourcePath -Destination $LDAPSCertDestPath
}

Write-ScreenInfo "Enabling Auto-enrollment for Certificates"
Enable-LabCertificateAutoenrollment -Computer -User -CodeSigning
