New-Item -Path "HKLM:\Software\Policies\Microsoft\Edge" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "HideFirstRunExperience" -Value 1
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name "NewTabPageLocation" -Value "https://google.com"