Function Set-WeakPasswordPolicy {
    Write-Log -Message "Configuring Domain Password Policies"
    Get-ADDefaultDomainPasswordPolicy | Set-ADDefaultDomainPasswordPolicy -LockoutThreshold 0 -ComplexityEnabled $False -MinPasswordLength 4
}