Function Disable-SMBSigning {
    Write-Host "  [+] Disabling SMB Signing.." -ForegroundColor Green
    Set-SmbServerConfiguration -RequireSecuritySignature 0 -EnableSecuritySignature 0 -Confirm:$False
}