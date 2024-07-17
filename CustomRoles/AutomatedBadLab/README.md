# AutomatedBadLab

This Role is not designed to be a cyber range such as [GOAD](https://github.com/Orange-Cyberdefense/GOAD) but a user controlled vulnerable domain to practise TTPs on. However, the ATTACK vectors are provisioned in a way where a handful of random AD users will be explotiable via a "Primary" method, then each of these accounts will have random subset of "Second" ATTACK Vectors if you do want to use this as an environment to teach others. 

As these are all split into individual PowerShell functions, AutomatedBadLab also offers a reference for each of these misconfigurations to gain a better understanding of why they introduce vulnerabilities to a domain.

A snapshot of the Domain Controller is taken twice during this role, once when the machine is promoted to a DC, and once again when AutomatedBadLab has finished its misconfiguring.

## Defining the role

``` PowerShell
$AutomatedBadLabRole = Get-LabPostInstallationActivity -CustomRole AutomatedBadLab -Properties @{
   UserCount           = 100 # Default 1000,
   GroupCount          = 100 # Default 100
   ComputerCount       = 150 # Default 1500
   VulnerableUserCount = 10  # Default (Get-Random -Minimum 4 -Maximum 11)
}

Add-LabMachineDefinition -Name DC01 -Role RootDC -PostInstallationActivity $AutomatedBadLabRole
```

## Output

Details of vulnerable user accounts are saved to the local directory:
``` PowerShell
$DC = Get-LabVM -Role RootDC
$DCSession = New-LabPSSession -ComputerName $DC
Receive-File -SourceFilePath C:\AutomatedBadLab.log -DestinationFilePath ".\$($DC.DomainName)_AutomatedBadLab.log" -Session $DCSession
Write-ScreenInfo "Downloaded logs to $PSScriptRoot\$($DC.DomainName)_AutomatedBadLab.log"
```

An example log file snippet is provided below:
```
[+] CN=Hollie Summers,OU=ServiceAccounts,OU=AZR,OU=Stage,DC=badblood,DC=uk is ASREP roastable
[+] CN=Hollie Summers,OU=ServiceAccounts,OU=AZR,OU=Stage,DC=badblood,DC=uk has password 'qazwsxedc'
[+] CN=Hollie Summers,OU=ServiceAccounts,OU=AZR,OU=Stage,DC=badblood,DC=uk -[User-Force-Change-Password]-> CN=Aubrey Brennan,OU=Test,OU=OGC,OU=Stage,DC=badblood,DC=uk
[+] CN=Hollie Summers,OU=ServiceAccounts,OU=AZR,OU=Stage,DC=badblood,DC=uk -[msDS-KeyCredentialLink]-> CN=Persephone Wright,OU=ServiceAccounts,OU=SEC,OU=Stage,DC=badblood,DC=uk
[+] CN=Hollie Summers,OU=ServiceAccounts,OU=AZR,OU=Stage,DC=badblood,DC=uk can read CN=BBWS01,CN=Computers,DC=badblood,DC=uk LAPS password
[+] CN=Hollie Summers,OU=ServiceAccounts,OU=AZR,OU=Stage,DC=badblood,DC=uk -[GenericAll]-> CN=BBCA01,CN=Computers,DC=badblood,DC=uk
```

## Multi-Domains 
AutomatedBadLab is also supported in Root / Child Domains and Forest scenarios. The [Forest Template](../../Labs/1.%20Template%20Forest.ps1) script provides an example of how it can be deployed on multiple Domain Controllers. 

## Full list of supported ATTACK vectors
- "Primary"
    - Anonymous LDAP
    - Passwords in AD Description Fields
    - Users with Weak Passwords
    - ASREProasting
    - Kerberoasting
    - Pre-2K Computer Objects
    - Timeroasting
    - Enabled Guest User
    - SMB Password Capture
- "Secondary"
    - SMB Signing
    - Machine Coercion
    - SMB Reflection 
    - Weak Kerberos Crytography
    - NTLMv1
    - DACL Attacks
        - Targeted Kerberoasting
        - ForceChangePassword
        - Shadow Credentials
        - Resource-based constrained delegation (RBCD)
        - DCSync
        - Owner rights
    - Constrained / Unconstrained Delegation Attacks
    - DNSAdmins (No longer exploitable)
    - Group Policy Passwords
    - Users with Reversable Password Encryption
    - Local Administrator Password Solution (LAPS)
    - Group Managed Service Accounts (gMSAs)
    - Group Policy Object (GPO) Abuse
    - Protected Users Bypass
    - Active Directory Certificate Services (AD CS) ESC1-10b & 13
    - PrintNightmare Vulnerabilities
    - Foreign Memberships
    - BitLocker Recovery Keys

## Requirements
- None
