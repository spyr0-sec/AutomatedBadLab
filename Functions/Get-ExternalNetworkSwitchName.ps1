Function Get-ExternalNetworkSwitch {

    try {
        # HyperV can only have one External switch, so we need to find or create one
        $VMSwitch = Get-VMSwitch -SwitchType External
        
        if ($VMSwitch) {
            $ExternalSwitch = $VMSwitch
        } else {
            # Work out which network adapter is Internet connected
            $NetworkTest = Test-NetConnection -ComputerName 8.8.8.8 -Port 443
            
            if ($NetworkTest.TcpTestSucceeded) {
                $ExternalSwitch = New-VMSwitch -Name 'External' -NetAdapterName $NetworkTest.InterfaceAlias
            } else {
                throw "Non-Internet connected machine, please reconfigure with Internal or NAT switch"
            }
        }
    } catch {
        Write-Error $_.Exception.Message
        Exit 1
    }
    return $ExternalSwitch
}