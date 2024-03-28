param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

Import-Lab -Name $data.Name

Write-ScreenInfo "Waiting for updates to complete on $ComputerName"
Wait-LabVMRestart -ComputerName $ComputerName
