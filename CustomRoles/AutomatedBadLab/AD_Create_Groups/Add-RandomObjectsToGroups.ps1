Function Add-RandomObjectsToGroups {

    Write-Log -Message "Randomising Group Memberships"

    # Acquire needed AD information
    $allUsers = Get-ADUser -Filter *
    $allGroups = Get-ADGroup -Filter { GroupCategory -eq "Security" -and GroupScope -eq "Global" } -Properties isCriticalSystemObject
    $allGroupsLocal = Get-ADGroup -Filter { GroupScope -eq "domainlocal" } -Properties isCriticalSystemObject
    $allcomps = Get-ADComputer -Filter *

    # Calculate counts for randomness
    $UsersInGroupCount = [math]::Round($allUsers.count * 0.8)
    $GroupsInGroupCount = [math]::Round($allGroups.count * 0.2)
    $CompsInGroupCount = [math]::Round($allcomps.count * 0.1)

    $allGroupsFiltered = $allGroups | Where-Object -Property iscriticalsystemobject -ne $true

    # Add a large number of users to non-critical groups
    $AddUserstoGroups = Get-Random -Count $UsersInGroupCount -InputObject $allUsers

    foreach ($user in $AddUserstoGroups) {
        $numGroupsToAdd = 1..10 | Get-Random
        1..$numGroupsToAdd | ForEach-Object {
            $randogroup = $allGroupsFiltered | Get-Random
            try {
                Add-ADGroupMember -Identity $randogroup -Members $user
            } catch { }
        }
    }

    # Add users to critical groups, but not "Domain Users" or "Domain Guests"
    $allGroupsCrit = $allGroups | Where-Object { $_.iscriticalsystemobject -and $_.name -notin @("Domain Users", "Domain Guests") }

    $allGroupsCrit | ForEach-Object {
        $numUsersToAdd = 2..5 | Get-Random
        try {
            Add-ADGroupMember -Identity $_ -Members (Get-Random -Count $numUsersToAdd -InputObject $allUsers)
        } catch { }
    }

    # Add users to local groups
    $allGroupsLocal | ForEach-Object {
        $numUsersToAdd = 1..3 | Get-Random
        try {
            Add-ADGroupMember -Identity $_ -Members (Get-Random -Count $numUsersToAdd -InputObject $allUsers)
        } catch { }
    }

    # Nest groups
    $AddGroupstoGroups = Get-Random -Count $GroupsInGroupCount -InputObject $allGroupsFiltered

    foreach ($group in $AddGroupstoGroups) {
        $numGroupsToAdd = 1..2 | Get-Random
        1..$numGroupsToAdd | ForEach-Object {
            $randogroup = $allGroupsFiltered | Get-Random
            try {
                Add-ADGroupMember -Identity $randogroup -Members $group
            } catch { }
        }
    }

    # Add critical groups to random groups
    $allGroupsCrit | ForEach-Object {
        $numGroupsToAdd = 1..3 | Get-Random
        1..$numGroupsToAdd | ForEach-Object {
            $randogroup = $allGroupsFiltered | Get-Random
            try {
                Add-ADGroupMember -Identity $randogroup -Members $_
            } catch { }
        }
    }

    # Add computers to groups
    $addcompstogroups = Get-Random -Count $CompsInGroupCount -InputObject $allcomps

    foreach ($comp in $addcompstogroups) {
        $numGroupsToAdd = 1..5 | Get-Random
        1..$numGroupsToAdd | ForEach-Object {
            $randogroup = $allGroupsFiltered | Get-Random
            try {
                Add-ADGroupMember -Identity $randogroup -Members $comp
            } catch { }
        }
    }

    # Don't want any Protected Users as causes issues with exploitation
    Get-ADGroupMember -Identity 'Protected Users' | ForEach-Object { Remove-ADGroupMember -Identity 'Protected Users' -Members $_ -Confirm:$False }
}
