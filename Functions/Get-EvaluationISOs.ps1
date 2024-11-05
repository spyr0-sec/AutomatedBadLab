$LocalIsoPath = "$(Get-LabSourcesLocation)\ISOs"
Write-Host "[+] Downloading Windows ISOs to $LocalIsoPath. This may take a while.."

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

# Download Windows Server 2025 ISO
Write-Host "[+] Downloading Windows 2025 ISO"

$WS2025_ISO_URL = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1.240331-1435.ge_release_SERVER_EVAL_x64FRE_en-us.iso"
Start-BitsTransfer -Source $WS2025_ISO_URL -Destination "$LocalIsoPath\Windows_Server_2025_Evaluation.iso"

$WS2025_ISO_SHA256 = "16442D1C0509BCBB25B715B1B322A15FB3AB724A42DA0F384B9406CA1C124ED4"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2025_Evaluation.iso" -Algorithm SHA256).Hash -eq $WS2025_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2025 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2025 ISO checksum does not match"
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

$WS2019_ISO_SHA256 = "549BCA46C055157291BE6C22A3AAAED8330E78EF4382C99EE82C896426A1CEE1"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2019_Evaluation.iso" -Algorithm SHA256).Hash -eq $WS2019_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2019 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2019 ISO checksum does not match"
}

# Download Windows Server 2016 ISO
Write-Host "[+] Downloading Windows 2016 ISO"

$WS2016_ISO_URL = "https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"
Start-BitsTransfer -Source $WS2016_ISO_URL -Destination "$LocalIsoPath\Windows_Server_2016_Evaluation.iso"

$WS2016_ISO_SHA256 = "1CE702A578A3CB1AC3D14873980838590F06D5B7101C5DAACCBAC9D73F1FB50F"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2016_Evaluation.iso" -Algorithm SHA256).Hash -eq $WS2016_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2016 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2016 ISO checksum does not match"
}

# Download Windows Server 2012r2 ISO
Write-Host "[+] Downloading Windows 2012 R2 ISO"

$WS2012_ISO_URL = "http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO"
Start-BitsTransfer -Source $WS2012_ISO_URL -Destination "$LocalIsoPath\Windows_Server_2012_Evaluation.iso"

$WS2012_ISO_SHA256 = "6612B5B1F53E845AACDF96E974BB119A3D9B4DCB5B82E65804AB7E534DC7B4D5"
If ((Get-FileHash -Path "$LocalIsoPath\Windows_Server_2012_Evaluation.iso" -Algorithm SHA256).Hash -eq $WS2012_ISO_SHA256) {
    Write-Host "  [+] Windows Server 2012 R2 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Server 2012 ISO checksum does not match"
}

# Download Windows SQL 2019 ISO
Write-Host "[+] Downloading Windows SQL 2019 ISO"

$WSQL2019_ISO_URL = "https://download.microsoft.com/download/7/c/1/7c14e92e-bdcb-4f89-b7cf-93543e7112d1/SQLServer2019-x64-ENU.iso"
Start-BitsTransfer -Source $WSQL2019_ISO_URL -Destination "$LocalIsoPath\SQLServer2019-x64-ENU.iso"

$WSQL2019_ISO_SHA256 = "D2691A3E559392757934F6FA0C508E466A720D3C1FBCD8C2B62E0575EA1808BE"
If ((Get-FileHash -Path "$LocalIsoPath\SQLServer2019-x64-ENU.iso" -Algorithm SHA256).Hash -eq $WSQL2019_ISO_SHA256) {
    Write-Host "  [+] Windows SQL 2019 ISO checksum matches"
} else {
    Write-Host "  [!] Windows SQL 2019 ISO checksum does not match"
}

# Download Windows Office Pro Plus 2016 ISO
Write-Host "[+] Downloading Windows Office 2016 ISO"

$WO2016_ISO_URL = "https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-us/ProPlusRetail.img"
Start-BitsTransfer -Source $WO2016_ISO_URL -Destination "$LocalIsoPath\Office 2016 Professional.iso"

$WO2016_ISO_SHA256 = "67EA3C84E2D26DBDD1C3F72FB774F6DC72701DC2F96F19CBA0B70880A3B856E9"
If ((Get-FileHash -Path "$LocalIsoPath\Office 2016 Professional.iso" -Algorithm SHA256).Hash -eq $WO2016_ISO_SHA256) {
    Write-Host "  [+] Windows Office 2016 ISO checksum matches"
} else {
    Write-Host "  [!] Windows Office 2016 ISO checksum does not match"
}

# Download Ubuntu 24.04.1 x64 Server ISO
Write-Host "[+] Downloading Ubuntu 24.04.1 ISO"

$UBUNTU_2404_ISO_URL = "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
Start-BitsTransfer -Source $UBUNTU_2404_ISO_URL -Destination "$LocalIsoPath\Ubuntu_2404_Server.iso"

$UBUNTU_2404_ISO_SHA256 = "E240E4B801F7BB68C20D1356B60968AD0C33A41D00D828E74CEB3364A0317BE9"
If ((Get-FileHash -Path "$LocalIsoPath\Ubuntu_2404_Server.iso" -Algorithm SHA256).Hash -eq $UBUNTU_2404_ISO_SHA256) {
    Write-Host "  [+] Ubuntu 24.04.1 Server ISO checksum matches"
} else {
    Write-Host "  [!] Ubuntu 24.04.1 Server ISO checksum does not match"
}

# Download Kali Linux ISO
Write-Host "[+] Downloading Kali Linux 2024.2 ISO"

$KALI_2024_ISO_URL = "https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-installer-amd64.iso"
Start-BitsTransfer -Source $KALI_2024_ISO_URL -Destination "$LocalIsoPath\Kali_Linux_2024_2.iso"

$KALI_2024_ISO_SHA256 = "5EB9DC96CCCBDFE7610D3CBCED1BD6EE89B5ACDFC83FFEE1F06E6D02B058390C"
If ((Get-FileHash -Path "$LocalIsoPath\Kali_Linux_2024_2.iso" -Algorithm SHA256).Hash -eq $KALI_2024_ISO_SHA256) {
    Write-Host "  [+] Kali Linux 2024.2 ISO checksum matches"
} else {
    Write-Host "  [!] Kali Linux 2024.2 ISO checksum does not match"
}

Write-Host "[+] ISOs downloaded!"
