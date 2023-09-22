Write-Host "[+] Installing Application Guard Feature.." -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName Windows-Defender-ApplicationGuard -NoRestart

Write-Host "[+] Setting the registry keys to cicumvent hardware requirements.." -ForegroundColor Green
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Hvsi -Name SpecRequiredProcessorCount -PropertyType DWORD -Value 1
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Hvsi -Name SpecRequiredMemoryInGB -PropertyType DWORD -Value 2