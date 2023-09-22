# https://social.technet.microsoft.com/Forums/windows/en-US/82617035-254f-4078-baa2-7b46abb9bb71/newadserviceaccount-key-does-not-exist?forum=winserver8gen
Function New-gMSA {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][string[]]$VulnUsers
    )

    Write-Host "  [+] Provide a vulnerable user privileges to a gMSA account" -ForegroundColor Green

    # Obtain variables
    $gMSAUser = $VulnUsers | Get-Random
    $BLComputer = (Get-ADComputer -Filter 'Description -like "*AutomatedBadLab*"' | Get-Random).DNSHostName
    $Name = "SPFarm$(Get-Random -Minimum 1 -Maximum 9)"
 
    # Create the KDS Root Key 
    Add-KdsRootKey –EffectiveTime ((get-date).addhours(-10))

    # Create the gMSA
    New-ADServiceAccount $Name `
        -DNSHostName $BLComputer `
        -PrincipalsAllowedToRetrieveManagedPassword $gMSAUser `
        -KerberosEncryptionType RC4, AES128, AES256 `
        -ServicePrincipalNames `
            "http/$Name.$((Get-AdDomain).Forest)/$((Get-AdDomain).Forest)", `
            "http/$Name.$((Get-AdDomain).Forest)/$((Get-AdDomain).NetBIOSName)", `
            "http/$Name/$((Get-AdDomain).Forest)", `
            "http/$Name/$((Get-AdDomain).NetBIOSName)"
    
    Write-Verbose "$gMSAUser can retrieve $Name gMSA password"
}
