param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name -NoValidation -NoDisplay

Write-ScreenInfo "Local Privilege Escalation Workshop setup complete. Waiting for $ComputerName to restart before continuing"
Restart-LabVM -ComputerName $ComputerName -Wait
