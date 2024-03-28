Function Set-ESC7 {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    Write-Log -Message "Providing a vulnerable user danagerous rights over the CA Object (ESC7)"

    # Get two random and distinct users from $VulnUsers
    $SelectedVulnUsers = ($VulnUsers | Get-Random -Count 2)

    # 1 = ManageCA || 2 = Issue Certificates
    $AccessMask = 1
    
    Foreach ($VulnUser in $SelectedVulnUsers) {

        # Get the CA Objects to modify
        $CAComputer = Get-ADComputer -Identity (Get-ADGroupMember -Identity "Cert Publishers" | Where-Object objectClass -EQ computer).name
        $CAName = (Get-ADObject -LDAPFilter "(ObjectClass=certificationAuthority)" -SearchBase "CN=Certification Authorities,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)").Name

        $Paths = @("Configuration\$($CAName)", "Security")

        Foreach ($Path in $Paths) {

            If ($Path -eq "Security") {
                $AccessMask = 48
            }

            # Registry Path
            $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\$Path"

            Invoke-Command -ComputerName $CAComputer.Name -ScriptBlock {
                param($VulnUser, $AccessMask, $RegPath)

                $ace = New-Object System.Security.AccessControl.CommonAce ([System.Security.AccessControl.AceFlags]::None, [System.Security.AccessControl.AceQualifier]::AccessAllowed, $AccessMask, $VulnUser.SID, $false, $null)

                # Build the new ACL
                $binaryData = Get-ItemProperty -Path $RegPath -Name "Security"
                $sd = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList $binaryData.Security, 0

                $sd.DiscretionaryAcl.InsertAce($sd.DiscretionaryAcl.Count, $ace)
                $sdBytes = New-Object byte[] $sd.BinaryLength
                $sd.GetBinaryForm($sdBytes, 0)

                # Append new ACL to Security REG_BINARY blob
                Set-ItemProperty -Path $RegPath -Name "Security" -Value $sdBytes
                
                # Restart ADCS for the perms to take
                Restart-Service -Name 'Certsvc'

            } -ArgumentList $VulnUser, $AccessMask, $RegPath
        }

        If ($AccessMask -eq 1) {
            Write-Log -Message "$VulnUser has ManageCA Rights on $CAComputer" -Level "Informational"
        }
        Else {
            Write-Log -Message "$VulnUser has Issue and Manage Certificate Rights on $CAComputer" -Level "Informational"
        }

        # Give second user ManageCertificate Rights
        $AccessMask = 2 
    }
}
