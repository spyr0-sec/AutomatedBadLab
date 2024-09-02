Function Get-AvailableIPRanges {
    param (
        [Parameter(Mandatory=$false)]
        [ValidatePattern('\d{1,3}\.\d{1,3}\.\d{1,3}\.0')]
        [string]$IPAddress,
        [switch]$Available
    )

    # Retrieve current network ranges and their names
    $networks = Get-LabVirtualNetwork | Select-Object Name, @{Name='Network'; Expression={ $_.AddressSpace.Network.AddressAsString }}

    # Get the subnet prefix for created networks
    If ($null -eq $IPAddress) {
        $SubnetPrefix = ($networks | Where-Object { $_.Name -ne "Default Switch" } | Select-Object -First 1).Network.Split('.')[0..1] -join '.'
    } else {
        $SubnetPrefix = $IPAddress.Split('.')[0..1] -join '.'
    }

    # Define the total possible X values that are divisible by 10
    $totalXValues = 0..255 | Where-Object { $_ % 10 -eq 0 }

    # Initialize an array to hold the subnet status objects
    $subnetStatus = @()

    # Loop through each possible X value
    foreach ($x in $totalXValues) {
        # Construct the subnet address
        $subnet = "$SubnetPrefix.$x.0"
        
        # Check if the subnet is in use
        $inUse = $networks | Where-Object { $_.Network -eq $subnet }

        if ($IPAddress) {
            # If IP address parameter is given, check if it matches the current subnet
            if ($subnet -eq $IPAddress) {
                if ($inUse) {
                    # If the subnet is in use, return the resource name
                    return [PSCustomObject]@{
                        Subnet = $subnet
                        Availability = $inUse.Name
                    }
                } else {
                    # If the subnet is not in use, return 'Available'
                    return [PSCustomObject]@{
                        Subnet = $subnet
                        Availability = 'Available'
                    }
                }
            }
        } else {
            # If IP address parameter is not given and "available" switch is used, add only available subnets to the array
            if ($Available) {
                if (-not $inUse) {
                    $status = [PSCustomObject]@{
                        Subnet = $subnet
                        Availability = 'Available'
                    }
                    $subnetStatus += $status
                }
            } else {
                # If IP address parameter is not given and "available" switch is not used, add all subnets to the array
                if ($inUse) {
                    # If the subnet is in use, add it with the resource name
                    $status = [PSCustomObject]@{
                        Subnet = $subnet
                        Availability = $inUse.Name
                    }
                } else {
                    # If the subnet is not in use, mark it as available
                    $status = [PSCustomObject]@{
                        Subnet = $subnet
                        Availability = 'Available'
                    }
                }

                # Add the status object to the array
                $subnetStatus += $status
            }
        }
    }

    # Return the subnet status array if IP address parameter is not given
    if (-not $IPAddress) {
        return $subnetStatus
    }
}
