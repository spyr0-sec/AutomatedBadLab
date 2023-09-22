Function Enable-NTLMv1 {
    Write-Host "  [+] Enabling NTLMv1" -ForegroundColor Green
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LMCompatibilityLevel' -Value 1 -Type DWord
}