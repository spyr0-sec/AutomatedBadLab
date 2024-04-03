param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name -NoValidation -NoDisplay

Write-ScreenInfo "Windows Defender removed. Waiting for $ComputerName to restart before continuing"
Restart-LabVM -ComputerName $ComputerName -Wait
