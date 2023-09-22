Function Enable-AllKerbEncryptionTypes {

    Write-Host "  [+] Enabling all msDS-SupportedEncryptionTypes" -ForegroundColor Green

    # Create a new GPO
    $KerbEncGPOName = "KerberosEncryptionGPO" 
    New-GPO -Name $KerbEncGPOName -Comment "Permit all Kerberos Encryption Types for testing"

    # Set the required registry key for the Kerberos encryption type to allow DES
    $params = @{
        Name      = $KerbEncGPOName
        Key       = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
        ValueName = 'SupportedEncryptionTypes'
        Type      = 'Dword'
        Value     = 30
    }

    Set-GPRegistryValue @params

    # Link the GPO to the 'Domain Controllers' OU
    $dcOU = Get-ADOrganizationalUnit -Filter 'Name -like "Domain Controllers"' | Select-Object -ExpandProperty DistinguishedName
    New-GPLink -Name $KerbEncGPOName -Target $dcOU -LinkEnabled Yes

    # Force an immediate group policy update to apply
    Invoke-GPUpdate -RandomDelayInMinutes 0 
}