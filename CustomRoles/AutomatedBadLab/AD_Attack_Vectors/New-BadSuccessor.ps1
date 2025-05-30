Function New-BadSuccessor {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    # First check if all DCs are running Windows Server 2025
    $allDCs = Get-ADDomainController -Filter *

    foreach ($dc in $allDCs) {
        if ($dc.OperatingSystem -notlike "*Windows Server 2025*") {
            Write-Log -Message "Windows Server 2025 DCs required for DMSAs." -Level "Warning"
            return
        }
    }

    # Check for a CA within the environment, otherwise create Self-Signed Cert for LDAPS
    $ca = Get-ADCertificationAuthority -Filter * -ErrorAction SilentlyContinue
    if (-not $ca) {
        Write-Log -Message "No Certification Authority found, creating Self-Signed Certificate for LDAPS." -Level "Warning"
        New-SelfSignedCertificate -DnsName "LDAPS.$($env:COMPUTERNAME)" `
        -CertStoreLocation "Cert:\LocalMachine\My" -KeyUsage DigitalSignature, KeyEncipherment -Type SSLServerAuthentication
    }

    Write-Log -Message "Providing a vulnerable user CreateChild Rights on a Random OU"

    # Provide a vulnerable user Replication Extended Rights
    $BadSuccessor = $VulnUsers | Get-Random -ErrorAction SilentlyContinue

    $OU = Get-ADOrganizationalUnit -Filter * | Get-Random -ErrorAction SilentlyContinue

    # Crete a new ACE for the vulnerable user on the OU
    Set-ACE $BadSuccessor $OU "CreateChild"

    Write-Log -Message "$BadSuccessor has CreateChild rights on $OU" -Level "Informational"

}
