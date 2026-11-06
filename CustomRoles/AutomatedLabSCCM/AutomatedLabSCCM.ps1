# References:
# https://github.com/subat0mik/Misconfiguration-Manager/tree/main/attack-techniques
# https://specterops.io/blog/2024/03/05/misconfiguration-manager-overlooked-and-overprivileged/

param(
    [string]$SiteCode = 'LD1'
)

# Logger function
Function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet("Default", "Informational", "Warning")]
        [string]$Level = "Default"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    switch ($Level) {
        "Default"       { $LogMessage = "$Timestamp - [+] $Message" }
        "Informational" { $LogMessage = "$Timestamp -   [+] $Message" }
        "Warning"       { $LogMessage = "$Timestamp -   [!] $Message" }
    }

    $LogMessage | Out-File -FilePath "C:\AutomatedBadLabSCCM.log" -Append
}

# Import the Configuration Manager module
Import-Module ConfigurationManager

# Connect to the site
if (-not (Get-PSDrive -Name $SiteCode -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SiteCode -PSProvider 'AdminUI' -Root $SiteCode
}

Push-Location "$($SiteCode):\"

try {
    Write-Log -Message "(Mis)Configuring SCCM Site $SiteCode"

    $Domain = $env:USERDNSDOMAIN

    # ATTACK - Network Access Account (CRED-2, CRED-3, CRED-5)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-2/cred-2_description.md
    try {
        try {
            New-CMAccount -Name "$Domain\SCCM_NAA" -Password (ConvertTo-SecureString "Somepass1" -AsPlainText -Force) -SiteCode $SiteCode -EA Stop
        } catch {
            if ($_.Exception.Message -notmatch "already exists") { throw }
        }
        Set-CMSoftwareDistributionComponent -SiteCode $SiteCode -AddNetworkAccessAccountName "$Domain\SCCM_NAA"
        Write-Log -Message "SCCM_NAA configured as the Network Access Account (CRED-2/3/5)" -Level Informational
    } catch {
        Write-Log -Message "Network Access Account could not be configured: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - Task Sequence with "run as" credentials (CRED-3, CRED-4)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md
    try {
        $TS = Get-CMTaskSequence -Name "Vulnerable Deployment" -EA SilentlyContinue
        if (-not $TS) {
            $TS = New-CMTaskSequence -Name "Vulnerable Deployment" -CustomTaskSequence -EA Stop
            $Step = New-CMTaskSequenceStepRunCommandLine -Name "Run as Service Account" -CommandLine "cmd.exe /c echo Deploying" -RunAsUser -UserName "$Domain\SCCM_TS_Account" -UserPassword (ConvertTo-SecureString "Somepass2" -AsPlainText -Force) -EA Stop
            Add-CMTaskSequenceStep -TaskSequence $TS -Step $Step -EA Stop
        }
        Write-Log -Message "Task Sequence 'Vulnerable Deployment' created with embedded 'run as' credentials (CRED-3/4)" -Level Informational
    } catch {
        Write-Log -Message "Task Sequence could not be created: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - Collection Variables with secrets (CRED-3)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md
    try {
        $Collection = Get-CMDeviceCollection -Name "Vulnerable Devices" -EA SilentlyContinue
        if (-not $Collection) { $Collection = New-CMDeviceCollection -Name "Vulnerable Devices" -LimitingCollectionId 'SMS00001' }
        if ($Collection) {
            if (-not (Get-CMDeviceCollectionVariable -CollectionId $Collection.CollectionID -VariableName "AdminPassword" -EA SilentlyContinue)) {
                New-CMDeviceCollectionVariable -CollectionId $Collection.CollectionID -VariableName "AdminPassword" -Value "P@ssw0rd123!" -IsMask $true -EA Stop
            }
            if (-not (Get-CMDeviceCollectionVariable -CollectionId $Collection.CollectionID -VariableName "ServiceAccountPassword" -EA SilentlyContinue)) {
                New-CMDeviceCollectionVariable -CollectionId $Collection.CollectionID -VariableName "ServiceAccountPassword" -Value "S0meServ1ceP@ss" -IsMask $true -EA Stop
            }
            Write-Log -Message "Collection variables with masked secrets created on Vulnerable Devices (CRED-3)" -Level Informational
        }
    } catch {
        Write-Log -Message "Collection variables could not be created: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - Device Variables with secrets (CRED-3)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md
    try {
        $Device = Get-CMDevice -EA SilentlyContinue | Select-Object -First 1
        if ($Device) {
            if (-not @(Get-CMDeviceVariable -DeviceName $Device.Name -EA SilentlyContinue | Where-Object VariableName -eq "LocalAdminPassword")) {
                New-CMDeviceVariable -DeviceName $Device.Name -VariableName "LocalAdminPassword" -VariableValue "L0calAdm1nP@ss" -IsMask $true -EA Stop
            }
            Write-Log -Message "Device variable with masked secret created on $($Device.Name) (CRED-3)" -Level Informational
        }
    } catch {
        Write-Log -Message "Device variables could not be created: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - CM Account with weak credentials (CRED-3)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md
    try {
        New-CMAccount -Name "$Domain\SCCM_TS_Account" -Password (ConvertTo-SecureString "Somepass2" -AsPlainText -Force) -SiteCode $SiteCode -EA Stop
        Write-Log -Message "CM Account created for SCCM_TS_Account (CRED-3)" -Level Informational
    } catch {
        if ($_.Exception.Message -match "already exists") {
            Write-Log -Message "CM Account for SCCM_TS_Account already exists (CRED-3)" -Level Informational
        } else {
            Write-Log -Message "CM Account could not be created: $($_.Exception.Message)" -Level Warning
        }
    }

    # ATTACK - PXE without password protection (CRED-1, ELEVATE-4, ELEVATE-5)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-1/cred-1_description.md
    try {
        $DP = Get-CMDistributionPoint -EA SilentlyContinue | Select-Object -First 1
        if ($DP) {
            Set-CMDistributionPoint -SiteSystemServerName $DP.NetworkOsPath -EnablePxe $true -EnableNonWdsPxe $true -AllowPxeResponse $true -EA Stop
            Write-Log -Message "PXE enabled without password protection on $($DP.NetworkOsPath) (CRED-1/ELEVATE-4/5)" -Level Informational
        }
    } catch {
        Write-Log -Message "PXE could not be configured: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - Anonymous Distribution Point access (CRED-6)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-6/cred-6_description.md
    try {
        $DP = Get-CMDistributionPoint -EA SilentlyContinue | Select-Object -First 1
        if ($DP) {
            Set-CMDistributionPoint -SiteSystemServerName $DP.NetworkOsPath -EnableAnonymous $true -EA Stop
            Write-Log -Message "Anonymous access enabled on Distribution Point $($DP.NetworkOsPath) (CRED-6)" -Level Informational
        }
    } catch {
        Write-Log -Message "Anonymous DP access could not be enabled: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - Client Push Installation with NTLM fallback (ELEVATE-2, ELEVATE-3)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/ELEVATE/ELEVATE-2/ELEVATE-2_description.md
    try {
        Set-CMClientPushInstallation -SiteCode $SiteCode -EnableAutomaticClientPushInstallation $true -AllownNTLMFallback $true -EnableSystemTypeWorkstation $true -EnableSystemTypeServer $true -EA Stop
        Write-Log -Message "Automatic Client Push Installation enabled with NTLM fallback (ELEVATE-2/3)" -Level Informational
    } catch {
        Write-Log -Message "Client Push could not be configured: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - Dangerous approved script (EXEC-2)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/EXEC/EXEC-2/exec-2_description.md
    try {
        $Script = Get-CMScript -ScriptName "Vulnerable Script" -EA SilentlyContinue
        if (-not $Script) {
            $ScriptText = 'Write-Host "Hello from AutomatedLabSCCM"'
            $Script = New-CMScript -ScriptName "Vulnerable Script" -ScriptText $ScriptText -EA Stop
            try {
                Start-Sleep -Seconds 2
                Approve-CMScript -ScriptGuid $Script.ScriptGuid -EA Stop
                Write-Log -Message "Script 'Vulnerable Script' created and approved (EXEC-2)" -Level Informational
            } catch {
                Write-Log -Message "Script 'Vulnerable Script' created, approval pending (EXEC-2)" -Level Informational
            }
        } else {
            Write-Log -Message "Script 'Vulnerable Script' already exists (EXEC-2)" -Level Informational
        }
    } catch {
        Write-Log -Message "Script could not be created: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - Loose permissions with a lazy admin (various)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/RECON/RECON-5/recon-5_description.md
    try {
        $ExistingAdmin = Get-CMAdministrativeUser -EA SilentlyContinue | Where-Object { $_.Name -match "SCCM_LazyAdmin" -or $_.LogonName -match "SCCM_LazyAdmin" }
        if (-not $ExistingAdmin) {
            New-CMAdministrativeUser -Name "$Domain\SCCM_LazyAdmin" -RoleName "Full Administrator" -EA Stop
        }
        Write-Log -Message "SCCM_LazyAdmin granted the Full Administrator role (RECON-5/various)" -Level Informational
    } catch {
        Write-Log -Message "Loose permissions could not be configured: $($_.Exception.Message)" -Level Warning
    }

    # ATTACK - Package with loose access permissions (CRED-6)
    # https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-6/cred-6_description.md
    try {
        $Package = Get-CMPackage -Name "Vulnerable Package" -EA SilentlyContinue
        if (-not $Package) {
            $Package = New-CMPackage -Name "Vulnerable Package" -EA Stop
        }
        if ($Package) {
            try {
                New-CMAccessAccount -UserName "BUILTIN\Everyone" -AccountType 'WindowsGroup' -PackageId $Package.PackageID -Access 'Read' -EA Stop
            } catch {
                if ($_.Exception.Message -notmatch "already exists") { throw }
            }
            Write-Log -Message "Package 'Vulnerable Package' created with Everyone:Read access (CRED-6)" -Level Informational
        }
    } catch {
        Write-Log -Message "Package could not be created: $($_.Exception.Message)" -Level Warning
    }

} finally {
    Pop-Location
}
