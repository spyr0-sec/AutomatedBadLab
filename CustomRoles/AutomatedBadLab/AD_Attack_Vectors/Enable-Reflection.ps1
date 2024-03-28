# https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/accessing-server-locally-with-fqdn-cname-alias-denied

Function Enable-Reflection {
    Write-Log -Message "Enabling SMB Relay Reflection Attack"
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'DisableLoopbackCheck' -Value 1 -Type DWord
}