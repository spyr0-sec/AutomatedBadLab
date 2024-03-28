# https://sensepost.com/blog/2023/protected-users-you-thought-you-were-safe-uh/

Function Enable-ProtectedAdmin {
    Write-Log -Message "Added 500 Account to Protected Users"
    Add-ADGroupMember -Identity "Protected Users" -Members "Administrator"
}