Function New-DACLAttacks {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    Write-Host "  [+] Providing vulnerable users write property permissions / extended rights over other users" -ForegroundColor Green

    # All vulnerable AD Rights
    $ActiveDirectoryRights = @('GenericAll', 'GenericWrite', 'Self', 'WriteDacl', 'WriteOwner', 'WriteProperty', 'ExtendedRight')

    # Attributes value : GUID mapping
    $AttributesMap = @{
        "servicePrincipalName" = "f3a64788-5306-11d1-a9c5-0000f80367c1"
        "msDS-KeyCredentialLink" = "5b47d60f-6090-40b2-9f37-2a4de88f3063"
        "msDS-AllowedToDelegateTo" = "800d94d7-b7a1-42a1-b14d-7cae1423d07f"
        "msDS-AllowedToActOnBehalfOfOtherIdentity" = "3f78c3e5-f79a-46bd-a0b8-9d18116ddc79"
    }

    # Extended rights value : GUID mapping
    $ExtendedRightsMap = @{
        "User-Force-Change-Password" = "00299570-246d-11d0-a768-00aa006e0529"
    }

    # Ensure these all get executed a few times
    $executionCounts = @{
        'Set-RandomACL' = $ActiveDirectoryRights.Count + $VulnUsers.Count
        'Set-WritePermission' = $AttributesMap.Count + $VulnUsers.Count
        'Set-ExtendedRight' = $ExtendedRightsMap.Count + $VulnUsers.Count
    }

    # Keep going until all attacks have been introduced multiple times 
    While (($executionCounts.Values | Where-Object { $_ -gt 0 }).Count -gt 0) {

        # Get our compromised user and a random victim user
        $VulnUser = $VulnUsers | Get-Random
        $VictimUser = Get-ADUser -Filter * | Get-Random

        # Pick a AD right to apply
        $Right = $ActiveDirectoryRights | Get-Random
    
        # Create our vulnerable DACL 
        Switch ($Right) {
            { $_ -in @('GenericAll', 'GenericWrite', 'Self', 'WriteDacl', 'WriteOwner') } { 
                if ($executionCounts['Set-RandomACL'] -gt 0) {
                    Set-RandomACL $VulnUser $VictimUser $Right
                    $executionCounts['Set-RandomACL']--
                }
            }
            'WriteProperty' { 
                if ($executionCounts['Set-WritePermission'] -gt 0) {
                    Set-WritePermission $VulnUser $VictimUser ($AttributesMap.GetEnumerator() | Get-Random)
                    $executionCounts['Set-WritePermission']-- 
                }
            }
            'ExtendedRight' { 
                if ($executionCounts['Set-ExtendedRight'] -gt 0) {
                    Set-ExtendedRight $VulnUser $VictimUser ($ExtendedRightsMap.GetEnumerator() | Get-Random)
                    $executionCounts['Set-ExtendedRight']--
                }
            }
        }
    }
}