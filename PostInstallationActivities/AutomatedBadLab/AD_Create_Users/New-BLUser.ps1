﻿Function New-BLUser {

    # Creates new AD user with random attributes

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][int32]$UserCount
    )

    Write-Host "[+] Creating $UserCount AutomatedBadLab Users.." -ForegroundColor Green
    
    for ($CreatedUsers= 1; $CreatedUsers -le $UserCount; $CreatedUsers++) {
        # Get Random OU to put our user into
        $OUPath = (ADOrganizationalUnit -Filter * | Get-Random).DistinguishedName

        $Description = "User generated by AutomatedBadLab"
        
        # Give a small percent chance of created user being a service account
        $accountType = 1..100 | Get-Random
        If ($accountType -le 3) { 
            # Format SA-########
            $ServicePrefix = "SA-"   
            $UserName = "$ServicePrefix" + (Get-Random -Minimum 100 -Maximum 9999999999)
            $FirstName = "Service"
            $Surname = "Account"
            $HumanName = "$FirstName $Surname"
        }
        Else {
            # Create normal user. Format First.Name
            $Surname = Get-Content -Path (Join-Path $PSScriptRoot 'Names\top1000-uk-surnames.txt') | Get-Random
            
            $Gender = "M","F" | Get-Random
            If ($Gender -eq "F") { 
                $FirstName = Get-Content -Path (Join-Path $PSScriptRoot 'Names\top1000-uk-female-names.txt') | Get-Random
            }
            Else {
                $FirstName = Get-Content -Path (Join-Path $PSScriptRoot 'Names\top1000-uk-female-names.txt') | Get-Random
            }
            $UserName = "$FirstName.$Surname"
            $HumanName = "$FirstName $Surname"
        }

        # Track progress
        Write-Progress -Id 1 -Activity "Creating AD Users.." -Status "Creating User $CreatedUsers of $UserCount" `
        -CurrentOperation $Username -PercentComplete ($CreatedUsers / $UserCount * 100)

        $UPN = "$Username@$((Get-AdDomain).Forest)"

        # Generate Passwords
        $Password = New-Password
        
        # Max AD Username length is 20, cut if longer 
        If ($UserName.length -gt 20) {
            Write-Verbose "$UserName has account name > 20 characters. Shortening to $($UserName.Substring(0,20))"
            $UserName = $UserName.substring(0,20)
        }

        # Final check account to ensure does not already exist before creating
        If (-not [bool] (Get-ADUser -Filter { SamAccountName -eq $UserName })) {
            New-ADUser -SamAccountName $UserName -DisplayName $HumanName -Name $HumanName -GivenName $FirstName `
            -Surname $Surname -Description $Description -UserPrincipalName $UPN -EmailAddress $UPN -Enabled $True -Path $OUPath `
            -AccountPassword (ConvertTo-SecureString ($Password) -AsPlainText -Force)
        }

    }
}

Write-Progress -Id 1 -Activity "Created AD Users" -Completed