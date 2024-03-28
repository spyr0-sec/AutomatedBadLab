Function Set-DCLocation {

    Write-Log -Message "Reverting DC Location back to the Domain Controllers OU"

    # Ensure the DC is in the correct OU
    $DCDistinguishedName = (Get-ADDomainController).ComputerObjectDN
    $DCContainer = (Get-ADDomain).DomainControllersContainer

    Move-ADObject -Identity $DCDistinguishedName -TargetPath $DCContainer
}