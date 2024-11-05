Function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [ValidateSet("Default", "Informational", "Warning")]
        [string]$Level = "Default"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    switch ($Level) {
        "Default"       { $LogMessage = "$Timestamp - [+] $Message" }
        "Informational" { $LogMessage = "$Timestamp -   [+] $Message" }
        "Warning"       { $LogMessage = "$Timestamp -   [!] $Message" }
    }
    
    $LogMessage | Out-File -FilePath "C:\OffensivePipeline.log" -Append
}

$ToolsDir = "C:\OffensivePipeline"
$TempDir = "C:\OffensivePipeline\Temp"
$ToolsZip = "$ToolsDir\OffensivePipeline.zip"
$OffensivePipelineZipURL = "https://github.com/Aetsu/OffensivePipeline/releases/download/v2.0.0/OfensivePipeline_v2.0.0.zip"

Write-Log -Message "Installing Visual Studio 2022 Build Tools"
Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_buildtools.exe' -OutFile "$TempDir\vs_buildtools.exe"
& "$TempDir\vs_buildtools.exe" --quiet --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools

Write-Log -Message "Installing Reference Assemblies"
$DestDir = "C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\"
$Numbers = @("40","45","451","452","46","461","462","47","471","472","48","481")

# Hacky way but satsifies reference assemblies system-wide 
foreach ($Number in $Numbers) {

    # Map number to .NET Framework version
    $ZipFile = "$TempDir\$($Number)RefAss.zip"
    If ($Number.Length -eq 2) {
        $Version = "v$($Number[0]).$($Number[1])"
    }
    If ($Number.Length -eq 3) {
        $Version = "v$($Number[0]).$($Number[1]).$($Number[2])"
    }

    Write-Log -Message "Installing reference assemblies for .NET Framework $Version"
    
    # Download and extract reference assemblies
    Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.NETFramework.ReferenceAssemblies.net$Number/1.0.3" -OutFile $ZipFile
    Expand-Archive $ZipFile -DestinationPath "$TempDir\$Version"

    # Move to correct location
    Copy-Item -Recurse -Force -Path "$TempDir\$Version\build\.NETFramework\$Version" -Destination $DestDir
}

Write-Log -Message "Downloading latest OffensivePipeline release"
Invoke-WebRequest -Uri $OffensivePipelineZipURL -OutFile $ToolsZip

Expand-Archive $ToolsZip -DestinationPath $ToolsDir

Write-Log -Message "Downloading NuGet and installing packages"
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile "$TempDir\nuget.exe"

Write-Log -Message "Obfuscating Tools"
C:\OffensivePipeline\OfensivePipeline_v2.0.0\OffensivePipeline.exe all

Write-Log -Message "Finished"
