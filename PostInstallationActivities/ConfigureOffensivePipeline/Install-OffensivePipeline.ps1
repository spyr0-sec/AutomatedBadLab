$ToolsDir = "C:\OffensivePipeline"
$TempDir = "$ToolsDir\Temp"
$ToolsZip = "$ToolsDir\OffensivePipeline.zip"
$ZipSHA256 = "e974fbcba4f740c34d5721de91b103b1a9c380d2fbf6d2f21ddffad51aa3d0a5"

# Create directory and exclude it from Windows defender
New-Item -ItemType Directory -Path $TempDir -Force
Set-MpPreference -ExclusionPath $ToolsDir
Add-MpPreference -ExclusionExtension “exe”
Add-MpPreference -ExclusionExtension “bin”

## Setup pre-reqs
Write-Host "[+] Installing .Net Framework 3.5" -ForegroundColor Green
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All

Write-Host "[+] Installing Visual Studio 2022 Build Tools" -ForegroundColor Green
Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_buildtools.exe' -OutFile "$TempDir\vs_buildtools.exe"
C:\OffensivePipeline\Temp\vs_buildtools.exe --quiet --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools

Write-Host "[+] Downloading latest OffensivePipeline release" -ForegroundColor Green
Invoke-WebRequest -Uri "https://github.com/Aetsu/OffensivePipeline/releases/download/v2.0.0/OfensivePipeline_v2.0.0.zip" -OutFile $ToolsZip

If ($(Get-FileHash $ToolsZip -Algorithm SHA256).Hash -eq $ZipSHA256.ToUpper() ) {
    Write-Host "[+] Integrity check passed" -ForegroundColor Green
}
Else {
    Write-Host "[+] Integrity check failed. Try installing Offensive Pipeline zip again." -ForegroundColor Red
    Exit
}

Write-Host "[+] Installing Reference Assemblies" -ForegroundColor Green
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

    Write-Verbose "Installing reference assemblies for .NET Framework $Version"
    
    # Download and extract reference assemblies
    Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.NETFramework.ReferenceAssemblies.net$Number/1.0.3" -OutFile $ZipFile
    Expand-Archive $ZipFile -DestinationPath "$TempDir\$Version"

    # Move to correct location
    Copy-Item -Recurse -Force -Path "$TempDir\$Version\build\.NETFramework\$Version" -Destination $DestDir
}

Expand-Archive $ToolsZip -DestinationPath $ToolsDir

Write-Host "[+] Downloading NuGet and installing packages" -ForegroundColor Green
Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $ToolsDir\OfensivePipeline_v2.0.0\Resources\nuget.exe
C:\OffensivePipeline\OfensivePipeline_v2.0.0\Resources\nuget.exe sources add -Name Offensive -Source https://nuget.code-offensive.net/v3/index.json
C:\OffensivePipeline\OfensivePipeline_v2.0.0\Resources\nuget.exe install C:\packages.config

Write-Host "[+] Obfuscating Tools" -ForegroundColor Green
C:\OffensivePipeline\OfensivePipeline_v2.0.0\OffensivePipeline.exe all

Write-Host "[+] Finished" -ForegroundColor Green