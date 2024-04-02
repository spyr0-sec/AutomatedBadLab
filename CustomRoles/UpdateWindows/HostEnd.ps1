param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name -NoValidation

Write-ScreenInfo "Waiting for updates to complete on $ComputerName"
Wait-LabVMRestart -ComputerName $ComputerName
