# Helper script to downgrade AutomatedLab to a specific version. Run in a fresh PwSh session
# v5.51.0 has an issue with network creation / deletion
# https://github.com/AutomatedLab/AutomatedLab/issues/1391
# AutomatedLab.Common is still stuck on v2.3.25 so excluded from downgrade

Get-Module AutomatedLab* | Remove-Module -Verbose

$latestAutomatedLabVersion = (Find-Module AutomatedLabCore).Version
$requiredAutomatedLabVersion = "5.50.0"

Install-Module -Name AutomatedLab -RequiredVersion $requiredAutomatedLabVersion -Force -SkipPublisherCheck -AllowClobber
If ( $requiredAutomatedLabVersion -ne $latestAutomatedLabVersion ) {
    "AutomatedLabDefinition", "AutomatedLabNotifications", "AutomatedLabTest", "AutomatedLabWorker", "AutomatedLabUnattended", "AutomatedLab.Ships", "AutomatedLab.Recipe", "AutomatedLabCore" | ForEach-Object {
        Uninstall-Module -Name $_ -RequiredVersion $latestAutomatedLabVersion -Verbose -Force
        Install-Module -Name $_ -RequiredVersion $requiredAutomatedLabVersion -Verbose -Force -SkipPublisherCheck -AllowClobber
    }
}

Import-Module AutomatedLab -Force
Get-Module AutomatedLab*
