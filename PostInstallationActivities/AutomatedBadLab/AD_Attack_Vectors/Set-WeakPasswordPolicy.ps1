Function Set-WeakPasswordPolicy {
    Write-Host "[+] Configuring Domain Password Policies.." -ForegroundColor Green
    Get-ADDefaultDomainPasswordPolicy | Set-ADDefaultDomainPasswordPolicy -LockoutThreshold 0 -ComplexityEnabled $False -MinPasswordLength 4
}