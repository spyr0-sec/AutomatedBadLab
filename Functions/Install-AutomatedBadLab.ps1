Write-Host "[+] Installing AutomatedLab module"
Install-PackageProvider Nuget -Force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module AutomatedLab -SkipPublisherCheck -AllowClobber

Write-Host "[+] Configuring AutomatedLab"
Enable-LabHostRemoting -Force
New-LabSourcesFolder -DriveLetter C

$LocalIsoPath = "$(Get-LabSourcesLocation)\ISOs"
Write-Host "[+] Downloading Windows ISOs to $LocalIsoPath. This may take a while.."

# Download Windows 10 22H2 ISO
$WIN10_22H2_ISO_URL = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
Invoke-WebRequest -Uri $WIN10_22H2_ISO_URL -OutFile "$LocalIsoPath\Windows10_22H2_Enterprise_Evaluation.iso"

$WIN10_22H2_ISO_SHA256 = "EF7312733A9F5D7D51CFA04AC497671995674CA5E1058D5164D6028F0938D668"
If ((Get-FileHash -Path "$LocalIsoPath\Windows10_22H2_Enterprise_Evaluation.iso" -Algorithm SHA256).Hash -eq $WIN10_22H2_ISO_SHA256) {
    Write-Host "  [+] Windows 10 22H2 ISO checksum matches"
} else {
    Write-Host "  [!] Windows 10 22H2 ISO checksum does not match"
}

# Download Windows 11 22H2 ISO
$WIN11_22H2_ISO_URL = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66751/22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
Invoke-WebRequest -Uri $WIN11_22H2_ISO_URL -OutFile "$LocalIsoPath\Windows11_22H2_Enterprise_Evaluation.iso"

$WIN11_22H2_ISO_SHA256 = "EBBC79106715F44F5020F77BD90721B17C5A877CBC15A3535B99155493A1BB3F"
If ((Get-FileHash -Path "$LocalIsoPath\Windows11_22H2_Enterprise_Evaluation.iso" -Algorithm SHA256).Hash -eq $WIN11_22H2_ISO_SHA256) {
    Write-Host "  [+] Windows 11 22H2 ISO checksum matches"
} else {
    Write-Host "  [!] Windows 11 22H2 ISO checksum does not match"
}

# Download Windows Server 2022 ISO
$WS2022_ISO_URL = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
Invoke-WebRequest -Uri $WS2022_ISO_URL -OutFile "$LocalIsoPath\Windows_Server_2022_Evaluation.iso"

$WS2022_ISO_SHA256 = "3E4FA6D8507B554856FC9CA6079CC402DF11A8B79344871669F0251535255325"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2022_Evaluation.iso" -Algorithm SHA256).Hash -eq $WS2022_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2022 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2022 ISO checksum does not match"
}

Write-Host "[+] AutomatedLab setup complete!"
