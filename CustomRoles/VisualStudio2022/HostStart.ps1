param
(
    [Parameter(Mandatory)]
    [string]
    $ComputerName
)

Import-Lab -Name $data.Name -NoValidation

# Specify locations
$VS2022FilePath = "$labSources\SoftwarePackages\vs2022_community.exe"

# https://learn.microsoft.com/en-gb/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022
if (-not (Test-Path -Path $VS2022FilePath))
{
    # Download bootstrapper to local machine
    $VS2022URL = 'https://aka.ms/vs/17/release/vs_community.exe'
    Get-LabInternetFile -Uri $VS2022URL -Path $VS2022FilePath 
}

# Upload executable to machine
Copy-LabFileItem -Path $VS2022FilePath -ComputerName $ComputerName -DestinationFolderPath 'C:\VisualStudio2022'
$VS2022LocalFilePath = 'C:\VisualStudio2022\vs2022_community.exe'

# Step 2 - Install Visual Studio core, C++ / C# environments, Git for Windows and GitHub extention
$jobs = @()

# https://docs.microsoft.com/en-gb/visualstudio/install/command-line-parameter-examples?view=vs-2022
$jobs = Install-LabSoftwarePackage -LocalPath $VS2022LocalFilePath `
-CommandLine " --add Microsoft.VisualStudio.Component.CoreEditor --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.Git --add Component.GitHub.VisualStudio --includeRecommended --passive --wait" `
-ComputerName $ComputerName -AsJob -PassThru

Write-ScreenInfo -Message 'Waiting for Visual Studio 2022 Community to complete installation' -NoNewline

Wait-LWLabJob -Job $jobs -ProgressIndicator 15 -Timeout 30 -NoDisplay

Write-ScreenInfo "Finished installing Visual Studio 2022 Community on $ComputerName " -TaskEnd