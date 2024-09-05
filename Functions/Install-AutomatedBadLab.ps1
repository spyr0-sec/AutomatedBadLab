Write-Host "[+] Checking if HyperV is installed"

$os = Get-CimInstance -ClassName Win32_OperatingSystem
if ($os.ProductType -eq 1) {
    if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).State -ne "Enabled") {
        Write-Host "  [!] HyperV not found. Installing.."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart
        Write-Host "  [!] HyperV Installed! Please restart machine before building machines."
    }
    else {
        Write-Host "  [+] HyperV is already installed!"
    }
} else {
    if (!(Get-WindowsFeature -Name Hyper-V) -or (Get-WindowsFeature -Name Hyper-V).Installed -eq $false) {
        Write-Host "  [!] HyperV not found. Installing.."
        Install-WindowsFeature -Name Hyper-V -IncludeManagementTools
        Write-Host "  [!] HyperV Installed! Please restart machine before building machines."
    }
    else {
        Write-Host "  [+] HyperV is already installed!"
    }
}

Write-Host "[+] Installing AutomatedLab module"
Install-PackageProvider Nuget -Force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module AutomatedLab -SkipPublisherCheck -AllowClobber

Write-Host "[+] Configuring AutomatedLab"
Enable-LabHostRemoting -Force
New-LabSourcesFolder -DriveLetter C

$DownloadISOs = Read-Host "Do you want to download Evaluation ISOs? (Y/N)"
if ($DownloadISOs -eq "Y") {
    & "$PSScriptRoot\Get-EvaluationISOs.ps1"
}

Write-Host "[+] AutomatedLab setup complete!"
