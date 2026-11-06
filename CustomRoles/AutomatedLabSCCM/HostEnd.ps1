param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name -NoValidation -NoDisplay

# Take another snapshot of the CM server after we have made changes
Write-ScreenInfo "Creating snapshot of provisioned CM server"
Checkpoint-LabVM -ComputerName $ComputerName -SnapshotName "AutomatedLabSCCM Complete"

Write-ScreenInfo "AutomatedLabSCCM provisioning complete"

# Download the log to the host
$CMServer = Get-LabVM -ComputerName $ComputerName
$CMSession = New-LabPSSession -ComputerName $CMServer
Receive-File -SourceFilePath C:\AutomatedBadLabSCCM.log -DestinationFilePath "$PSScriptRoot\$($CMServer.DomainName)_AutomatedBadLabSCCM.log" -Session $CMSession
Remove-LabPSSession -ComputerName $ComputerName
Write-ScreenInfo "Downloaded logs to $PSScriptRoot\$($CMServer.DomainName)_AutomatedBadLabSCCM.log"
