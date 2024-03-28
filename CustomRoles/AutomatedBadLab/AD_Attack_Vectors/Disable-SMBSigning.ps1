Function Disable-SMBSigning {
    Write-Log -Message "Disabling SMB Signing"

    $ntdsPath = "C:\Windows\NTDS\ntds.dit"

    # If DC then configure via GPO
    If (Test-Path $ntdsPath) {
        Set-GPPrefRegistryValue -Name "Default Domain Controllers Policy" -Key "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -ValueName "RequireSecuritySignature" -Type DWord -Value 0 -Context Computer -Action Update
        Set-GPPrefRegistryValue -Name "Default Domain Controllers Policy" -Key "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -ValueName "EnableSecuritySignature" -Type DWord -Value 0 -Context Computer -Action Update
        Invoke-GPUpdate -RandomDelayInMinutes 0 
    }
    Else {
        Set-SmbServerConfiguration -RequireSecuritySignature 0 -EnableSecuritySignature 0 -Confirm:$False
    }
}