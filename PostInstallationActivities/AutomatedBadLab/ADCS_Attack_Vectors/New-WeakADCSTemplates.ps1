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


Function New-WeakADCSTemplates {
    
    # Get our Certificate Authority to install our Templates on
    $CertAuthority = (Get-LabVM -Role CaRoot)

    #--------------------------------------------------------------------------------------------------------------------
    # ESC1 - Combination of vulns (1) & (2) & (3) & (4) & (5) & (6)
    New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC1" -DisplayName "ESC1" -SourceTemplateName "User" `
                        -SamAccountName "Domain Users" -ComputerName $CertAuthority

    Invoke-LabCommand -ComputerName $CertAuthority -ActivityName "Configuring Client Authentication application policy & user supplied SANs" -ScriptBlock {
        Get-ADObject "CN=ESC1,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$((Get-ADRootDSE).defaultNamingContext)" -Properties * |
        Set-ADObject -Replace @{
            'msPKI-Certificate-Name-Flag' = 1
            'pKIExtendedKeyUsage' = '1.3.6.1.5.5.7.3.2'
        }
    }

    #--------------------------------------------------------------------------------------------------------------------
    # ESC2 - Combination of vulns (1) & (2) & (3) & (4) & (5) & (7)
    New-LabCATemplate -ApplicationPolicy 'ANY_APPLICATION_POLICY' -TemplateName "ESC2" -DisplayName "ESC2" -SourceTemplateName "User" `
                        -SamAccountName "Domain Users" -ComputerName $CertAuthority 

    Invoke-LabCommand -ComputerName $CertAuthority -ActivityName "Configuring Any Purpose application policy & user supplied SANs" -ScriptBlock {
        Get-ADObject "CN=ESC2,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$((Get-ADRootDSE).defaultNamingContext)" -Properties * |
        Set-ADObject -Replace @{
            'msPKI-Certificate-Name-Flag' = 1
            'pKIExtendedKeyUsage' = '2.5.29.37.0'
        }
    }

    #--------------------------------------------------------------------------------------------------------------------
    # ESC3 - Combination of vulns (1) & (2) & (3) & (7) & (8)
    New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC3" -DisplayName "ESC3" -SourceTemplateName "User" `
                        -SamAccountName "Domain Users" -ComputerName $CertAuthority 

    Invoke-LabCommand -ComputerName $CertAuthority -ActivityName "Configuring user supplied SANs" -ScriptBlock {
        $PKSContainer = "CN=Public Key Services,CN=Services,CN=Configuration,$((Get-ADRootDSE).defaultNamingContext)"
        Get-ADObject "CN=ESC3,CN=Certificate Templates,$PKSContainer" -Properties * | Set-ADObject -Add @{'msPKI-RA-Application-Policies' = '1.3.6.1.4.1.311.20.2.1'}
    }

    #--------------------------------------------------------------------------------------------------------------------
    # ESC4 - (9)
    New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC4" -DisplayName "ESC4" -SourceTemplateName "User" `
                        -SamAccountName "Enterprise Admins" -ComputerName $CertAuthority

    Invoke-LabCommand -ComputerName $CertAuthority -ActivityName "Providing GenericAll permission to Authenticated Users to ESC4 CA AD Object" -ScriptBlock {
        $AuthenticatedUsers = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-11')
        $GenericAll = [System.DirectoryServices.ActiveDirectoryRights]::GenericAll
        $Allow = [System.Security.AccessControl.AccessControlType]::Allow

        $ESC4Obj = "AD:CN=ESC4,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$((Get-ADRootDSE).defaultNamingContext)"

        $ESC4ACL = Get-Acl $ESC4Obj
        $ESC4AccessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $AuthenticatedUsers,$GenericAll,$Allow
        $ESC4ACL.AddAccessRule($ESC4AccessRule)
        Set-Acl $ESC4Obj -AclObject $ESC4ACL
    }

    #--------------------------------------------------------------------------------------------------------------------
    # ESC5 - This is around the security of the CA server itself
    # ATTACK vector in AutomatedBadLab

    #--------------------------------------------------------------------------------------------------------------------
    # ESC6 - Configure EDITF_ATTRIBUTESUBJECTALTNAME2 (Set by default on CAs < May 2022)
    Invoke-LabCommand -ComputerName $CertAuthority -ActivityName "Configure EDITF_ATTRIBUTESUBJECTALTNAME2" -ScriptBlock {
        certutil -config \ -setreg policy\EditFlags +EDITF_ATTRIBUTESUBJECTALTNAME2
        Restart-Service -Name 'certsvc' -Force 
    }

    #--------------------------------------------------------------------------------------------------------------------
    # ESC7 - ManageCA / ManageCertificates Permissions
    # ATTACK vector in AutomatedBadLab

    #--------------------------------------------------------------------------------------------------------------------
    # ESC8 - Vulnerable IIS web enrollment
    Invoke-LabCommand -ComputerName $CertAuthority -ActivityName "Configure Certificate Enrollment Web Service" -ScriptBlock {
        Install-WindowsFeature -Name ADCS-Web-Enrollment
        Install-AdcsWebEnrollment -Force
    }

    #--------------------------------------------------------------------------------------------------------------------
    # ESC13 - OID Group Link
    New-LabCATemplate -ApplicationPolicy 'Client Authentication' -TemplateName "ESC13" -DisplayName "ESC13" -SourceTemplateName "User" `
                        -SamAccountName "Domain Users" -ComputerName $CertAuthority -Version 2
    
    Invoke-LabCommand -ComputerName $CertAuthority -ActivityName "Group Link OID to Users DN" -ScriptBlock {
        $PKSContainer = "CN=Public Key Services,CN=Services,CN=Configuration,$((Get-ADRootDSE).defaultNamingContext)"

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
    }
}