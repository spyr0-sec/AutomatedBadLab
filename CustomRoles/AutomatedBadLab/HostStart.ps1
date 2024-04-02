param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name -NoValidation

# Take a snapshot of the DC before we start making changes
Write-ScreenInfo "Creating snapshot of base DC"
Checkpoint-LabVM -ComputerName $ComputerName -SnapshotName "Pre-AutomatedBadLab"

Write-ScreenInfo "Creating GPPPassword files"
Copy-LabFileItem -ComputerName $ComputerName -Recurse -Path "$PSScriptRoot\AD_Attack_Vectors\GPPPassword\{CB3BB981-8104-4332-AC09-909595804905}" -Destination "C:\Windows\Sysvol\domain\Policies\"

Write-ScreenInfo "Provisioning AD via AutomatedBadLab"
