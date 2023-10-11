# https://sensepost.com/blog/2023/protected-users-you-thought-you-were-safe-uh/

Function Enable-ProtectedAdmin {
    Write-Host "  [+] Added 500 Account to Protected Users" -ForegroundColor Green
    Add-ADGroupMember -Identity "Protected Users" -Members "Administrator"
}