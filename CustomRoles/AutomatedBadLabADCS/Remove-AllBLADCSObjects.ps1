# Deletes all ADCS objects created by AutomatedBadLab - useful for debugging

Function Remove-AllBLADCSObjects {

    # Cleanup all ADCS Objects created by AutomatedBadLab
    $CertAuthority = (Get-LabVM -Role CaRoot)

    Invoke-LabCommand -ComputerName $CertAuthority -ActivityName "Remove AutomatedBadLab Certifcate Templates" -ScriptBlock {
        $CAObjects = Get-ADObject -Filter * -SearchBase "CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)" -SearchScope 2 | Where-Object name -like "*ESC*"

        # Remove the CA AD Object as well as the CA Template
        foreach ($CAObject in $CAObjects) {
            Remove-ADObject -Identity $CAObject.DistinguishedName -Confirm:$False
            Remove-CATemplate -Name $CAObject.Name -Force -Confirm:$False
        }

        # Finally remove the ESC13 AD Group
        Remove-ADGroup -Identity "ESC13" -Confirm:$False
    }
}