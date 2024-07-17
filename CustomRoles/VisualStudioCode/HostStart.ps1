param
(
    [Parameter(Mandatory)]
    [string]
    $ComputerName
)

# Import Lab
Import-Lab -Name $data.Name -NoValidation -NoDisplay

# Specify locations
$VSCodeFilePath = "$labSources\SoftwarePackages\VSCode.exe"

if (-not (Test-Path -Path $VSCodeFilePath))
{
    # Download bootstrapper to local machine
    $VSCodeURL = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
    Get-LabInternetFile -Uri $VSCodeURL -Path $VSCodeFilePath 
}

# Upload executable to machine
Copy-LabFileItem -Path $VSCodeFilePath -ComputerName $ComputerName -DestinationFolderPath 'C:\VSCode'
$VSCodeLocalFilePath = 'C:\VSCode\VSCode.exe'

# Step 2 - Install Visual Studio Code
$jobs = @()

$jobs = Install-LabSoftwarePackage -LocalPath $VSCodeLocalFilePath `
-CommandLine " /VERYSILENT /NORESTART /MERGETASKS=!runcode" -ComputerName $ComputerName -AsJob -PassThru

Write-ScreenInfo -Message 'Waiting for Visual Studio Code to complete installation' -NoNewline

Wait-LWLabJob -Job $jobs -ProgressIndicator 15 -Timeout 30 -NoDisplay

Write-ScreenInfo "Finished installing Visual Studio Code on $ComputerName " -TaskEnd