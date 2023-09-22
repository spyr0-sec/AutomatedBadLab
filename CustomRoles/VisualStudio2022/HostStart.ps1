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

# Specify locations
$VS2022FilePath = "$labSources\SoftwarePackages\vs2022_community.exe"

# Download bootstrapper to local machine
# https://learn.microsoft.com/en-gb/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022
$VS2022URL = 'https://aka.ms/vs/17/release/vs_community.exe'

Get-LabInternetFile -Uri $VS2022URL -Path $VS2022FilePath 

if (-not (Test-Path -Path $VS2022FilePath))
{
    Write-Error "$VS2022FilePath could not be found. Download from $VS2022URL"
    return
}

Write-ScreenInfo -Message 'Waiting for machines to startup' -NoNewline
Start-LabVM -ComputerName $ComputerName -Wait -ProgressIndicator 15

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