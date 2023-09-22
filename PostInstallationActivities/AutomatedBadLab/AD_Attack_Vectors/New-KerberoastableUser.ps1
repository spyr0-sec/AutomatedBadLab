Function New-KerberoastableUser {

    # Adds SPNs for given number of AD Objects

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][int32]$KerbUserCount
    )

    Write-Host "  [+] Configuring $KerbUserCount Users to be Kerberoastable" -ForegroundColor Green
    
    $KerbUsers = @()
    $ServiceClass = @("HTTP", "HOST", "TERMSRV", "MSSQLSvc", "CIFS", "POP3")
        
    for ($Counter = 1; $Counter -le $KerbUserCount; $Counter++) {
        $BLComputer = (Get-ADComputer -Filter 'Description -like "*AutomatedBadLab*"' | Get-Random).DNSHostName
        $BLUser = Get-ADUser -Filter {Description -like "*AutomatedBadLab*" -and ServicePrincipalNames -notlike "*"} -Property ServicePrincipalNames | Get-Random
        $SPN = "$($ServiceClass | Get-Random)/$BLComputer"

        Write-Verbose "Setting SPN '$SPN' for $($BLUser.SamAccountName)"
            
        Try { 
            $BLUser | Set-ADUser -ServicePrincipalNames @{Add = $SPN } -ErrorAction Stop
            $KerbUsers += "$($BLUser.SamAccountName)"
        }
        Catch { 
            # Error, try again with a different user
            $Counter--
        }  
    }
    
    # Return the number of users that were made Kerberoastable
    return $KerbUsers
}
    