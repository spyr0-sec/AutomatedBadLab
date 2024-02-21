AutomatedBadLab
========
This PostInstallationActivity is not designed to be a cyber range such as [GOAD](https://github.com/Orange-Cyberdefense/GOAD) but a user controlled vulnerable domain to practise TTPs on. However, the ATTACK vectors are provisioned in a way where a handful of random AD users will be explotiable via a "Primary" method, then each of these accounts will have random subset of "Second" ATTACK Vectors if you do want to use this as an environment to teach others. 

As these are all split into individual PowerShell functions, AutomatedBadLab also offers a reference for each of these misconfigurations to gain a better understanding of why they introduce vulnerabilities to a domain.

Out of the box this will provision (quanities configurable in Invoke-AutomatedBadLab.ps1):
- 1000 AD Users
- 1500 AD Computers
- 100 AD Groups
- Randomise group memberships & permissions
- Implement ATTACK vectors

Details of which user accounts and their vulnerabilities will be outputted as verbose strings as seen in the example below as well as within a Transcript log file:
```
VERBOSE: Setting SPN 'HOST/LAPTOP-AA490611.badblood.uk' for Nancie.Holmes 
VERBOSE: Nancie.Holmes has the password 'JukI_G9;{Fh>i*7;.SWM]L' in their description field 
VERBOSE: Configured Nancie.Holmes to use DES Kerberos encryption 
VERBOSE: CN=Nancie Holmes,OU=Groups,OU=BDE,OU=Tier 1,DC=badblood,DC=uk -[GenericAll]-> CN=Faith Neal,OU=T0-Devices,OU=Tier0,OU=Admin,DC=badblood,DC=uk
VERBOSE: CN=Nancie Holmes,OU=Groups,OU=BDE,OU=Tier 1,DC=badblood,DC=uk -[msDS-AllowedToActOnBehalfOfOtherIdentity]-> CN=Rebecca Barron,OU=Devices,OU=AZR,OU=Tier 2,DC=badblood,DC=uk
```

## Full list of supported ATTACK vectors
- "Primary"
    - Anonymous LDAP
    - Passwords in AD Description Fields
    - Users with Weak Passwords
    - ASREProasting
    - Kerberoasting
    - Pre-2K Computer Objects
    - Timeroasting
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
    - Active Directory Certificate Services (AD CS) ESC1-8 & 13
    - PrintNightmare Vulnerabilities
