Function Enable-Reflection {
    Write-Host "  [+] Enabling SMB Relay Reflection Attack" -ForegroundColor Green
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'DisableLoopbackCheck' -Value 1 -Type DWord
}