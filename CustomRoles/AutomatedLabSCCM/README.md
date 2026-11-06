# AutomatedLabSCCM

This Role introduces the SCCM misconfigurations documented in the [Misconfiguration Manager](https://github.com/subat0mik/Misconfiguration-Manager) attack techniques to the Configuration Manager site.

## Defining the role

``` PowerShell
$SCCMPostInstallJobs = @()
$SCCMPostInstallJobs += Get-LabPostInstallationActivity -CustomRole AutomatedLabSCCM

# This needs to be run after the Configuration Manager role has been installed
$CMRole = Get-LabMachineRoleDefinition -Role ConfigurationManager -Properties @{
    Version      = '2203'
    Roles        = 'Management Point,Distribution Point,Software Update Point,Reporting Services Point,Endpoint Protection Point'
    SiteName     = 'London'
    SiteCode     = 'LD1'
    DatabaseName = 'CMDB'
}

Add-LabMachineDefinition -Name BBCM01 -Roles $CMRole -PostInstallationActivity $SCCMPostInstallJobs
```

## Deployment Details

The role creates the following misconfigurations

- Creates the following vulnerable AD Accounts
  - `SCCM_NAA` with the password `Somepass1`
  - `SCCM_TS_Account` with the password `Somepass2`
  - `SCCM_LazyAdmin` with the password `Password123!`

- Introduces the following SCCM Misconfigurations

| Technique | Description | Attack Reference |
| --------- | ----------- | ---------------- |
| Network Access Account | `SCCM_NAA` configured as the NAA | [CRED-2](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-2/cred-2_description.md), [CRED-3](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md), [CRED-5](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-5/cred-5_description.md) |
| Task Sequence with "run as" | Task Sequence with embedded `SCCM_TS_Account` credentials | [CRED-3](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md), [CRED-4](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-4/cred-4_description.md) |
| Collection Variables with secrets | Masked `AdminPassword` and `ServiceAccountPassword` on the Vulnerable Devices collection | [CRED-3](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md) |
| Device Variables with secrets | Masked `LocalAdminPassword` on the first device | [CRED-3](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md) |
| CM Account with weak credentials | `SCCM_TS_Account` stored as a CM Account | [CRED-3](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-3/cred-3_description.md) |
| PXE without password | PXE enabled responding without a password | [CRED-1](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-1/cred-1_description.md), [ELEVATE-4](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/ELEVATE/ELEVATE-4/ELEVATE-4_description.md), [ELEVATE-5](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/ELEVATE/ELEVATE-5/ELEVATE-5_description.md) |
| Anonymous Distribution Point access | Anonymous access enabled on the DP | [CRED-6](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-6/cred-6_description.md) |
| Client Push with NTLM fallback | Automatic Client Push enabled with NTLM fallback | [ELEVATE-2](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/ELEVATE/ELEVATE-2/ELEVATE-2_description.md), [ELEVATE-3](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/ELEVATE/ELEVATE-3/ELEVATE-3_description.md) |
| Dangerous Script | A PowerShell script ready to be approved and invoked | [EXEC-2](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/EXEC/EXEC-2/exec-2_description.md) |
| Loose permissions | `SCCM_LazyAdmin` granted the Full Administrator role | [RECON-5](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/RECON/RECON-5/recon-5_description.md) |
| Package with loose access | Package with Everyone:Read access | [CRED-6](https://github.com/subat0mik/Misconfiguration-Manager/blob/main/attack-techniques/CRED/CRED-6/cred-6_description.md) |

## Output

Details of the misconfigurations are saved to the local directory:
``` PowerShell
$CMServer = Get-LabVM -Role ConfigurationManager
$CMSession = New-LabPSSession -ComputerName $CMServer
Receive-File -SourceFilePath C:\AutomatedBadLabSCCM.log -DestinationFilePath ".\$($CMServer.DomainName)_AutomatedBadLabSCCM.log" -Session $CMSession
Write-ScreenInfo "Downloaded logs to $PSScriptRoot\$($CMServer.DomainName)_AutomatedBadLabSCCM.log"
```

## Requirements

- This role must be run on a machine with the `ConfigurationManager` role installed
- The Configuration Manager site must be fully installed before this role runs
