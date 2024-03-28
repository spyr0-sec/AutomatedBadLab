param(
    [Parameter(Mandatory)]
    [string]$ComputerName,

    [Parameter(Mandatory)]
    [string]$ATAIsoFilePath
)

Import-Lab -Name $data.Name

# Check if the ISO file exists
If (-not (Test-Path -Path $ATAIsoFilePath))
{
    Write-Error "The ISO file '$ATAIsoFilePath' could not be found."
    return
}

# Mount the ISO onto the target machine
Write-ScreenInfo "Mounting Microsoft ATA ISO on '$ComputerName'" -NoNewLine
$ATADisk = Mount-LabIsoImage -ComputerName $ComputerName -IsoPath $ATAIsoFilePath -PassThru -SupressOutput

# Copy the setup.exe to the filesystem
Invoke-LabCommand -ActivityName 'Copy setup.exe to filesystem' -ComputerName $ComputerName -ScriptBlock {
    New-Item -ItemType Directory -Path C:\MicrosoftATA | Out-Null
    Copy-Item -Path "$($args[0])\Microsoft ATA Center Setup.exe" -Destination "C:\MicrosoftATA\MicrosoftATACenterSetup.exe"
} -ArgumentList $ATADisk.DriveLetter

# Dismount the ISO
Dismount-LabIsoImage -ComputerName $ComputerName -SupressOutput
Write-ScreenInfo "Finished with ISO, dismounting"

$jobs = @()

# Silently install Microsoft ATA
$jobs = Install-LabSoftwarePackage -LocalPath "C:\MicrosoftATA\MicrosoftATACenterSetup.exe" -CommandLine " /quiet --LicenseAccepted NetFrameworkCommandLineArguments=`"/q`"" -ComputerName $ComputerName -AsJob -PassThru

Write-ScreenInfo -Message 'Waiting for Microsoft Advanced Threat Analytics to complete installation'
Wait-LWLabJob -Job $jobs -ProgressIndicator 15 -Timeout 30 -NoDisplay
Write-ScreenInfo "Finished installing Microsoft Advanced Threat Analytics on $ComputerName " -TaskEnd
