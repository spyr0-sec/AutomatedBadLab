$LocalIsoPath = "$(Get-LabSourcesLocation)\ISOs"
Write-Host "[+] Downloading Windows ISOs to $LocalIsoPath. This may take a while.."

# Download Windows 10 22H2 ISO
Write-Host "[+] Downloading Windows 10 ISO"

$WIN10_22H2_ISO_URL = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
Start-BitsTransfer -Source $WIN10_22H2_ISO_URL -Destination "$LocalIsoPath\Windows10_22H2_Enterprise_Evaluation.iso"

$WIN10_22H2_ISO_SHA256 = "EF7312733A9F5D7D51CFA04AC497671995674CA5E1058D5164D6028F0938D668"
If ((Get-FileHash -Path "$LocalIsoPath\Windows10_22H2_Enterprise_Evaluation.iso" -Algorithm SHA256).Hash -eq $WIN10_22H2_ISO_SHA256) {
    Write-Host "  [+] Windows 10 22H2 ISO checksum matches"
} else {
    Write-Host "  [!] Windows 10 22H2 ISO checksum does not match"
}

# Download Windows 11 22H2 ISO
Write-Host "[+] Downloading Windows 11 ISO"

$WIN11_22H2_ISO_URL = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66751/22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
Start-BitsTransfer -Source $WIN11_22H2_ISO_URL -Destination "$LocalIsoPath\Windows11_22H2_Enterprise_Evaluation.iso"

$WIN11_22H2_ISO_SHA256 = "EBBC79106715F44F5020F77BD90721B17C5A877CBC15A3535B99155493A1BB3F"
If ((Get-FileHash -Path "$LocalIsoPath\Windows11_22H2_Enterprise_Evaluation.iso" -Algorithm SHA256).Hash -eq $WIN11_22H2_ISO_SHA256) {
    Write-Host "  [+] Windows 11 22H2 ISO checksum matches"
} else {
    Write-Host "  [!] Windows 11 22H2 ISO checksum does not match"
}

# Download Windows Server 2022 ISO
Write-Host "[+] Downloading Windows 2022 ISO"

$WS2022_ISO_URL = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
Start-BitsTransfer -Source $WS2022_ISO_URL -Destination "$LocalIsoPath\Windows_Server_2022_Evaluation.iso"

$WS2022_ISO_SHA256 = "3E4FA6D8507B554856FC9CA6079CC402DF11A8B79344871669F0251535255325"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2022_Evaluation.iso" -Algorithm SHA256).Hash -eq $WS2022_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2022 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2022 ISO checksum does not match"
}

# Download Windows Server 2019 ISO
Write-Host "[+] Downloading Windows 2019 ISO"

$WS2019_ISO_URL = "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
Start-BitsTransfer -Source $WS2019_ISO_URL -Destination "$LocalIsoPath\Windows_Server_2019_Evaluation.iso"

$WS2019_ISO_SHA256 = "549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2019_Evaluation.iso" -Algorithm SHA256).Hash -eq $WS2019_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2019 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2019 ISO checksum does not match"
}

# Download Windows Server 2016 ISO
Write-Host "[+] Downloading Windows 2016 ISO"

$WS2016_ISO_URL = "https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"
Start-BitsTransfer -Source $WS2016_ISO_URL -Destination "$LocalIsoPath\Windows_Server_2016_Evaluation.iso"

$WS2016_ISO_SHA256 = "70721288BBCDFE3239D8F8C0FAE55F1F"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2016_Evaluation.iso" -Algorithm MD5).Hash -eq $WS2016_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2016 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2016 ISO checksum does not match"
}

# Download Windows Server 2012r2 ISO
Write-Host "[+] Downloading Windows 2012r2 ISO"

$WS2012_ISO_URL = "http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO"
Start-BitsTransfer -Source $WS2012_ISO_URL -Destination "$LocalIsoPath\Windows_Server_2012_Evaluation.iso"

$WS2012_ISO_SHA256 = "5b5e08c490ad16b59b1d9fab0def883a"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2012_Evaluation.iso" -Algorithm MD5).Hash -eq $WS2012_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2012 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2012 ISO checksum does not match"
}

# Download Ubuntu 22.04 x64 Server ISO
Write-Host "[+] Downloading Ubuntu 22.04 ISO"

$Ubuntu2204_ISO_URL = "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso"
Start-BitsTransfer -Source $Ubuntu2204_ISO_URL -Destination "$LocalIsoPath\Ubuntu_2204_Server.iso"

$Ubuntu2204_ISO_SHA256 = "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
If ((Get-FileHash -Path "$LocalIsoPath\Ubuntu_2204_Server.iso" -Algorithm SHA256).Hash -eq $Ubuntu2204_ISO_SHA256) {
    Write-Host "  [+] Ubuntu 2204 Server ISO checksum matches"
} else {
    Write-Host "  [!] Ubuntu 2204 Server ISO checksum does not match"
}

Write-Host "[+] ISOs downloaded!"
