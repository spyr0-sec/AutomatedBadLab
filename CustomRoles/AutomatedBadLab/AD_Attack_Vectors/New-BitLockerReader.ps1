Function New-BitLockerReader {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$VulnUsers
    )

    Write-Log -Message "Providing a vulnerable user ability to read BitLocker Recovery Keys"

    # Get random vulnerable user
    $VulnUser = $VulnUsers | Get-Random -ErrorAction SilentlyContinue

    # Pick a random AutomatedBadLab computer 
    $VictimComputer = Get-ADComputer -Filter { Description -eq "Computer generated by AutomatedBadLab" } | Select-Object -First 1
    
    # Get the BitLocker Recovery Key for the computer    
    $VictimKey = Get-ADObject -SearchBase $VictimComputer.DistinguishedName -Filter 'objectClass -eq "msFVE-RecoveryInformation"'
    
    # Set the vulnerable user to have GenericAll permissions on the BitLocker Recovery Key
    # NOTE: ReadProperty does not allow you to read the msFVE-RecoveryPassword attribute, only GenericAll gives you that right
    Set-ACE $VulnUser $VictimKey "GenericAll"
}
