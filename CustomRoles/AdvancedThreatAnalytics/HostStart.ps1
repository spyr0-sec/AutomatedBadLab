param
(
    [Parameter(Mandatory)]
    [string]
    $ComputerName
)

$lab = Import-Lab -Name $data.Name -NoValidation -NoDisplay -PassThru

if (-not $lab)
{
    Write-Error -Message 'Please deploy a lab first.'
    return
}

$ATAIsoFileName = 'mu_advanced_threat_analytics_ata_version_1.9_x64_dvd_11796945.iso'
$ATAIsoFilePath = Join-Path -Path $labSources\ISOs -ChildPath $ATAIsoFileName

if (-not (Test-Path -Path $ATAIsoFilePath))
{
    Write-Error "The ISO file '$ATAIsoFilePath' could not be found."
    return
}

Write-ScreenInfo -Message 'Waiting for machines to startup' -NoNewline
Start-LabVM -ComputerName $ComputerName -Wait -ProgressIndicator 15

# Done 
Write-ScreenInfo "Mounting Microsoft ATA ISO on '$ComputerName'..." -NoNewLine
$disk = Mount-LabIsoImage -ComputerName $ComputerName -IsoPath $ATAIsoFilePath -PassThru -SupressOutput

# Done
Invoke-LabCommand -ActivityName 'Copy setup.exe to filesystem' -ComputerName $ComputerName -ScriptBlock {
New-Item -ItemType Directory -Path C:\MicrosoftATA | Out-Null
Copy-Item -Path "$($args[0])\Microsoft ATA Center Setup.exe" -Destination "C:\MicrosoftATA\MicrosoftATACenterSetup.exe"
} -ArgumentList $disk.DriveLetter

Dismount-LabIsoImage -ComputerName $ComputerName -SupressOutput
Write-ScreenInfo 'Finished with ISO, dismounting..'

$jobs = @()

# Have put the setup.exe localy so need -LocalPath parameter - https://docs.microsoft.com/en-us/advanced-threat-analytics/ata-silent-installation#ata-gateway-silent-installation
$jobs = Install-LabSoftwarePackage -LocalPath "C:\MicrosoftATA\MicrosoftATACenterSetup.exe" -CommandLine " /quiet --LicenseAccepted NetFrameworkCommandLineArguments=`"/q`"" -ComputerName $ComputerName -AsJob -PassThru

Write-ScreenInfo -Message 'Waiting for Microsoft Advanced Threat Analytics to complete installation' -NoNewline

Wait-LWLabJob -Job $jobs -ProgressIndicator 15 -Timeout 30 -NoDisplay

Write-ScreenInfo "Finished installing Microsoft Advanced Threat Analytics on $ComputerName " -TaskEnd