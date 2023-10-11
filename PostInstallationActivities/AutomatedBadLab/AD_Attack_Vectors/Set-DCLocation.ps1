Function Set-DCLocation {

    # Ensure the DC is in the correct OU
    $DCDistinguishedName = (Get-ADDomainController).ComputerObjectDN
    $DCContainer = (Get-ADDomain).DomainControllersContainer

    Move-ADObject -Identity $DCDistinguishedName -TargetPath $DCContainer
}