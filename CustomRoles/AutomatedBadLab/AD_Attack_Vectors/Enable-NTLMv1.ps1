Function Enable-NTLMv1 {
    Write-Log -Message "Enabling NTLMv1"
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LMCompatibilityLevel' -Value 1 -Type DWord
}