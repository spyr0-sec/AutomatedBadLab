function Get-ISO {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Path,
        [string]$Sha256
    )

    Write-Host "[+] Processing $Name"

    # 1. If file exists, verify checksum first
    if (Test-Path $Path) {
        Write-Host "  [=] ISO already exists. Verifying checksum..."
        $localHash = (Get-FileHash -Path $Path -Algorithm SHA256).Hash

        if ($localHash -eq $Sha256) {
            Write-Host "  [+] Checksum OK — skipping download"
            return
        }
        else {
            Write-Host "  [!] Checksum mismatch — re-downloading ISO"
            Remove-Item $Path -Force
        }
    }

    # 2. Download ISO
    Write-Host "  [+] Downloading $Name"
    Start-BitsTransfer -Source $Url -Destination $Path

    # 3. Verify checksum after download
    Write-Host "  [+] Verifying checksum..."
    $downloadHash = (Get-FileHash -Path $Path -Algorithm SHA256).Hash

    if ($downloadHash -eq $Sha256) {
        Write-Host "  [+] $Name checksum matches"
    }
    else {
        Write-Host "  [!] $Name checksum does NOT match — deleting corrupt file"
        Remove-Item $Path -Force
    }
}

# -------------------------
# BEGIN ISO DEFINITIONS
# -------------------------

$LocalIsoPath = "$(Get-LabSourcesLocation)\ISOs"
Write-Host "[+] Downloading Windows ISOs to $LocalIsoPath"

# Windows 11 22H2
Get-ISO -Name "Windows 11 22H2" `
        -Url "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66751/22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso" `
        -Path "$LocalIsoPath\Windows11_22H2_Enterprise_Evaluation.iso" `
        -Sha256 "EBBC79106715F44F5020F77BD90721B17C5A877CBC15A3535B99155493A1BB3F"

# Windows 10 22H2
Get-ISO -Name "Windows 10 22H2" `
        -Url "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso" `
        -Path "$LocalIsoPath\Windows10_22H2_Enterprise_Evaluation.iso" `
        -Sha256 "EF7312733A9F5D7D51CFA04AC497671995674CA5E1058D5164D6028F0938D668"

# Windows Server 2025 (Insider — URL may break)
Get-ISO -Name "Windows Server 2025" `
        -Url "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1.240331-1435.ge_release_SERVER_EVAL_x64FRE_en-us.iso" `
        -Path "$LocalIsoPath\Windows_Server_2025_Evaluation.iso" `
        -Sha256 "16442D1C0509BCBB25B715B1B322A15FB3AB724A42DA0F384B9406CA1C124ED4"

# Windows Server 2022
Get-ISO -Name "Windows Server 2022" `
        -Url "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso" `
        -Path "$LocalIsoPath\Windows_Server_2022_Evaluation.iso" `
        -Sha256 "3E4FA6D8507B554856FC9CA6079CC402DF11A8B79344871669F0251535255325"

# Windows Server 2019
Get-ISO -Name "Windows Server 2019" `
        -Url "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso" `
        -Path "$LocalIsoPath\Windows_Server_2019_Evaluation.iso" `
        -Sha256 "549BCA46C055157291BE6C22A3AAAED8330E78EF4382C99EE82C896426A1CEE1"

# Windows Server 2016
Get-ISO -Name "Windows Server 2016" `
        -Url "https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO" `
        -Path "$LocalIsoPath\Windows_Server_2016_Evaluation.iso" `
        -Sha256 "1CE702A578A3CB1AC3D14873980838590F06D5B7101C5DAACCBAC9D73F1FB50F"

# Windows Server 2012 R2
Get-ISO -Name "Windows Server 2012 R2" `
        -Url "http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO" `
        -Path "$LocalIsoPath\Windows_Server_2012_Evaluation.iso" `
        -Sha256 "6612B5B1F53E845AACDF96E974BB119A3D9B4DCB5B82E65804AB7E534DC7B4D5"

# SQL Server 2019
Get-ISO -Name "SQL Server 2019" `
        -Url "https://download.microsoft.com/download/7/c/1/7c14e92e-bdcb-4f89-b7cf-93543e7112d1/SQLServer2019-x64-ENU.iso" `
        -Path "$LocalIsoPath\SQLServer2019-x64-ENU.iso" `
        -Sha256 "D2691A3E559392757934F6FA0C508E466A720D3C1FBCD8C2B62E0575EA1808BE"

# Office 2016 ProPlus
Get-ISO -Name "Office 2016 ProPlus" `
        -Url "https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-us/ProPlusRetail.img" `
        -Path "$LocalIsoPath\Office2016_ProPlus.iso" `
        -Sha256 "67EA3C84E2D26DBDD1C3F72FB774F6DC72701DC2F96F19CBA0B70880A3B856E9"

# Ubuntu 24.04.1
Get-ISO -Name "Ubuntu 24.04.1 Server" `
        -Url "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso" `
        -Path "$LocalIsoPath\Ubuntu_2404_Server.iso" `
        -Sha256 "E240E4B801F7BB68C20D1356B60968AD0C33A41D00D828E74CEB3364A0317BE9"

# Kali Linux 2026.1
Get-ISO -Name "Kali Linux 2026.1" `
        -Url "https://cdimage.kali.org/kali-2026.1/kali-linux-2026.1-installer-amd64.iso" `
        -Path "$LocalIsoPath\kali-linux-2026.1-installer-amd64.iso" `
        -Sha256 "271477ad6ea2676c7346576971b9acc2d32fabd9c2bbaf0e6302397626149306"

Write-Host "[+] ISO processing complete!"

