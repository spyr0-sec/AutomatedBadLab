param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name -NoValidation

# Take another snapshot of the DC after we have made changes
Write-ScreenInfo "Creating snapshot of provisioned DC"
Checkpoint-LabVM -ComputerName $ComputerName -SnapshotName "AutomatedBadLab Complete"

Write-ScreenInfo "AutomatedBadLab provisioning complete. Waiting for $ComputerName to restart before continuing"
Restart-LabVM -ComputerName $ComputerName -Wait

$DC = Get-LabVM -ComputerName $ComputerName
$DCSession = New-LabPSSession -ComputerName $DC
Receive-File -SourceFilePath C:\AutomatedBadLab.log -DestinationFilePath "$PSScriptRoot\$($DC.DomainName)_AutomatedBadLab.log" -Session $DCSession
Remove-LabPSSession -ComputerName $ComputerName
Write-ScreenInfo "Downloaded logs to $PSScriptRoot\$($DC.DomainName)_AutomatedBadLab.log"
