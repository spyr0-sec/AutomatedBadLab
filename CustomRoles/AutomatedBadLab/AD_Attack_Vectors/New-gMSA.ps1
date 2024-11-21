﻿# https://social.technet.microsoft.com/Forums/windows/en-US/82617035-254f-4078-baa2-7b46abb9bb71/newadserviceaccount-key-does-not-exist?forum=winserver8gen
Function New-gMSA {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    Write-Log -Message "Provide a vulnerable user privileges to a gMSA account"

    # Obtain variables
    $gMSAUser = $VulnUsers | Get-Random -ErrorAction SilentlyContinue
    $BLComputer = (Get-ADComputer -Filter 'Description -like "*AutomatedBadLab*"' | Get-Random).DNSHostName
    $Name = "SPFarm$(Get-Random -Minimum 1 -Maximum 9)"
 
    # Create the KDS Root Key
    Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))

    # Create the gMSA
    New-ADServiceAccount $Name `
        -DNSHostName $BLComputer `
        -PrincipalsAllowedToRetrieveManagedPassword $gMSAUser `
        -KerberosEncryptionType RC4, AES128, AES256 `
        -ServicePrincipalNames `
            "http/$Name.$((Get-AdDomain).DNSRoot)/$((Get-AdDomain).DNSRoot)", `
            "http/$Name.$((Get-AdDomain).DNSRoot)/$((Get-AdDomain).NetBIOSName)", `
            "http/$Name/$((Get-AdDomain).DNSRoot)", `
            "http/$Name/$((Get-AdDomain).NetBIOSName)"
    
    Write-Log -Message "$gMSAUser can retrieve $Name gMSA password" -Level "Informational"
}
