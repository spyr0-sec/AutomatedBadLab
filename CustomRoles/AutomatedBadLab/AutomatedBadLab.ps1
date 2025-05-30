[CmdletBinding()]
Param (
   [Parameter(Mandatory = $False)][int32]$UserCount = 1000,
   [Parameter(Mandatory = $False)][int32]$GroupCount = 100,
   [Parameter(Mandatory = $False)][int32]$ComputerCount = 150,
   [Parameter(Mandatory = $False)][int32]$VulnerableUserCount = (Get-Random -Minimum 4 -Maximum 11)
)

# Import all functions from AutomatedBadLab Module
$ABLFunctions = Get-ChildItem $PSScriptRoot -Recurse -Include "*.ps1" -File | Where-Object { $_.DirectoryName -ne $PSScriptRoot }

foreach ($ABLFunction in $ABLFunctions) {
    . $ABLFunction
}

# Import Active Directory Module
Import-Module ActiveDirectory

# Start the misconfiguration of the AD
Write-Log -Message "(Mis)Configuring $((Get-ADDomain).DNSRoot)"

# Weaken AD Password Policies
Set-WeakPasswordPolicy

# Organizational Unit Creation and structure
New-BLOUStructure

# User Creation
New-BLUser -UserCount $UserCount -ErrorAction SilentlyContinue

# Group Creation
New-BLGroup -GroupCount $GroupCount -ErrorAction SilentlyContinue

# Computer Creation
New-BLComputer -ComputerCount $ComputerCount -ErrorAction SilentlyContinue

# Randomise Group Memberships and Object Locations
Set-ABLObjectLocationAndMemberships

# Move DC back to the Domain Controllers OU
Set-DCLocation

# Start making the AD vulnerable and keep track of the vulnerable users
Write-Log -Message "Automating ATTACK Vectors"

# Primary Attack Vectors ------------------------------------------------------
# Make random number of users roastable, then provide them with passwords which are either weak or in the user description field

# Arrays to house the ADUser objects
$RoastableUsers = @()
$VulnUsers = @()

# ATTACK - Kerberoasting
$RoastableUsers += New-KerberoastableUser -KerbUserCount $([math]::Ceiling($VulnerableUserCount / 2)) 

# ATTACK - ASREP roasting
$RoastableUsers += New-ASREPUser -ASREPUserCount $([math]::Floor($VulnerableUserCount / 2)) 

# Shuffle these up and split into two arrays to pass to the password functions
$RoastableUsers = $RoastableUsers | Sort-Object { Get-Random }
$halfCount = [math]::Ceiling($RoastableUsers.Count / 2)
$FirstHalf = $RoastableUsers[0..($halfCount-1)]
$SecondHalf = $RoastableUsers[$halfCount..($RoastableUsers.Count-1)]

# ATTACK - Brute force roastable users
$VulnUsers += Set-WeakPassword -VulnUsers $FirstHalf 

# ATTACK - Plaintext passwords in description field
$VulnUsers += Set-PasswordInDescription -VulnUsers $SecondHalf 

# ATTACK - Add a final vulnerable user with blank password
$VulnUsers += Set-BlankPassword

# ATTACK - Pre 2k Computer Account
New-Pre2KComputerAccount 

# ATTACK - Enable Anonymous LDAP Read Access (Only needs to be once per forest)
If ((Get-ADDomain).DistinguishedName -eq (Get-ADRootDSE).rootDomainNamingContext) {
   Enable-AnonymousLDAP
}

# ATTACK - Enable Guest Account
Enable-GuestUser

# ATTACK - Create task to spray Administator password 
New-SMBSprayer

# Secondary Attack Vectors ----------------------------------------------------
# Now employ multiple attack vectors on our vulnerable users

# ATTACK - DNS Admin
New-DNSAdmin -VulnUsers $VulnUsers 

# ATTACK - Network Configuration Operator
New-NetworkConfigOperator -VulnUsers $VulnUsers

# ATTACK - Weak Kerberos Encryption
Enable-AllKerbEncryptionTypes 
New-DESKerberosUser -VulnUsers $VulnUsers 

# ATTACK - Reverable Password Encryption
New-ReversablePasswordUser -VulnUsers $VulnUsers 

# ATTACK - Group Managed Service Accounts (gMSA)
New-gMSA -VulnUsers $VulnUsers 

# ATTACK - Group Policy Passwords
Set-AdministratorPassword 

# ATTACK - DACL Attacks
New-DACLAttacks -VulnUsers $VulnUsers 

# ATTACK - Owner Attacks
New-Owner -VulnUsers $VulnUsers 

# ATTACK - DCSync Attack
New-DCSyncUser -VulnUsers $VulnUsers 

# ATTACK - Resource Based Constrained Delegation Attack
New-RBCDUser -VulnUsers $VulnUsers 

# ATTACK - Domain Controller GPO Abuse
New-DCGPO -VulnUsers $VulnUsers 

# ATTACK - Local Privileged Group Members
Add-LocalPrivilegedGroupMembers -VulnUsers $VulnUsers

# ATTACK - PowerShell Web Access
Enable-PowerShellWebAccess -VulnUsers $VulnUsers

# ATTACK - BadSuccessor DMSA Attack (Requires 2025 DC)
New-BadSuccessor -VulnUsers $VulnUsers

# ATTACK - Protected Users Bypass
Enable-ProtectedAdmin

# ATTACK - LAPS (available on OS > April 2023)
If (Get-Command Update-LapsADSchema -ErrorAction SilentlyContinue) {
   Install-LAPS -VulnUsers $VulnUsers
}

# ATTACK - ESC vulnerabilities
try {
   Get-ADObject -Filter { ObjectClass -eq 'certificationAuthority' } -SearchBase "CN=Certification Authorities,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)"
   Set-ESC5 -VulnUsers $VulnUsers 
   Set-ESC7 -VulnUsers $VulnUsers 
} catch {
   Write-Log -Message "No Certificate Authority on the local domain. Skipping ESC Vulnerabilities" -Level "Warning"
}

# ATTACK - PrintNightmare Vulnerabilities
Enable-PrintNightmare

# ATTACK - Weak SYSTEM Reg Hive 
New-SystemRegKey

# Machine Attack Vectors ------------------------------------------------------

# ATTACK - Enable NTLMv1
Enable-NTLMv1

# ATTACK - Disable SMB Signing
Disable-SMBSigning

# ATTACK - Enable SMB Reflection
Enable-Reflection

# DEFEND ----------------------------------------------------------------------

# Enable all Auditing types on the DC
Enable-AllDCAuditingEvents
