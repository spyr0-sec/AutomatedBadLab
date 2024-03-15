Function New-ASREPUser {

    # Reconfigures users to not require Pre Authentication

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][int32]$ASREPUserCount
    )

    Write-Host "  [+] Configuring No Pre-authentication for $ASREPUserCount Users" -ForegroundColor Green

    $ASREPUsers = New-Object 'System.Collections.Generic.List[Microsoft.ActiveDirectory.Management.ADUser]'
    
    for ($Counter = 1; $Counter -le $ASREPUserCount; $Counter++) {
        $BLUser = Get-ADUser -Filter {Description -like "*AutomatedBadLab*" -and DoesNotRequirePreAuth -eq "False"} -Property DoesNotRequirePreAuth | Get-Random
            
        Try { 
            $BLUser | Set-ADAccountControl -DoesNotRequirePreAuth:$True
            Write-Host "    [+] $BLUser is ASREP roastable" -ForegroundColor Yellow
            $ASREPUsers += $BLUser
        }
        Catch { 
            # Error, try again with a different user
            $Counter--
        }
    } 

    # Return the number of users that were made ASREP roastable
    return $ASREPUsers
}
