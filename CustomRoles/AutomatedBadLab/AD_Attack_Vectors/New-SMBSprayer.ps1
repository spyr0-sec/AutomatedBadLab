Function New-SMBSprayer {

    Write-Log -Message "Creating SMB Sprayer Scheduled Task"
   
    # Script to attempt SMB connections to all machines in local subnets
    $Command = @'
    # Get all network adapters
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

    # Loop through each network adapter
    foreach ($adapter in $adapters) {
        # Get the IP addresses of the adapter
        $ipAddresses = $adapter | Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' }

        # Loop through each IP address
        foreach ($ipAddress in $ipAddresses) {
            # Get the subnet of the IP address
            $subnet = $ipAddress.IPAddress -replace '\d+$'

            # Create a runspace pool
            $runspacePool = [RunspaceFactory]::CreateRunspacePool(1, 50)
            $runspacePool.Open()

            # Create a collection to hold the PowerShell jobs
            $jobs = New-Object System.Collections.ArrayList

            # Loop through all possible IP addresses in the subnet
            for ($i = 1; $i -le 254; $i++) {
                $ip = "$subnet$i"

                # Create a new PowerShell instance and add it to the runspace pool
                $ps = [PowerShell]::Create().AddScript({
                    param($ip)

                    # Use Test-Connection to check if the host is live
                    if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
                        Test-Path "\\$ip\share" -ErrorAction SilentlyContinue
                    }
                }).AddParameter('ip', $ip)

                $ps.RunspacePool = $runspacePool

                # Start the PowerShell job and add it to the collection
                $jobs.Add([PSCustomObject]@{Pipe = $ps; Result = $ps.BeginInvoke()}) | Out-Null
            }

            # Wait for all jobs to complete
            while ($jobs.Result.IsCompleted -contains $false) {
                Start-Sleep -Milliseconds 500
            }

            # Retrieve the results
            $results = $jobs | ForEach-Object {
                $_.Pipe.EndInvoke($_.Result)
            }

            # Close the runspace pool
            $runspacePool.Close()
        }
    }
'@

    $Command | Out-File -FilePath "C:\SMBSprayer.ps1" -Encoding UTF8

    # Enable Scheduled Task history logging for debugging
    wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true

    # Get the time 5 minutes from now
    $Time = (Get-Date).AddMinutes(5)

    # Create a new scheduled task trigger to run every 5 minutes
    $Trigger = New-ScheduledTaskTrigger -Once -At $Time -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 365)

    # Create a new action to run the PowerShell command
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\SMBSprayer.ps1"

    # Register the scheduled task
    Register-ScheduledTask -TaskName "SMBSprayerTask" -Trigger $Trigger -Action $Action -User "$((Get-ADDomain).DNSRoot)\Administrator" -Password "Passw0rd!" -Force
}
