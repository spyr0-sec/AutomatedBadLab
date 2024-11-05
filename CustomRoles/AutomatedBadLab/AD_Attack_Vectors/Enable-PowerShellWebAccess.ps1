Function Enable-PowerShellWebAccess {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Microsoft.ActiveDirectory.Management.ADUser[]]$VulnUsers
    )

    $PSWAUser = $VulnUsers | Get-Random

    Write-Log -Message "Enabling PowerShell Web Access and granting access to $PSWAUser"

    # Install the required features
    Install-WindowsFeature -Name WindowsPowerShellWebAccess, Web-Server -IncludeManagementTools

    # Install the web application with a self-signed certificate
    Install-PswaWebApplication -UseTestCertificate

    # Permit access to the web application for the vulnerable user
    Add-PswaAuthorizationRule -UserName "$((Get-ADDomain).NetBIOSName)\$($PSWAUser.SamAccountName)" -ComputerName * -ConfigurationName *
}
