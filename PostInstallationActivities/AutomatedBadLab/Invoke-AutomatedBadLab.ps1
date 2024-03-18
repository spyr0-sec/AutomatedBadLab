# Import all functions from AutomatedBadLab Module
Import-Module -Name (Join-Path $PSScriptRoot 'AutomatedBadLab.psm1') -Force

# AD Object type quantities
[int32]$UserCount = 1000
[int32]$GroupCount = 100
[int32]$ComputerCount = 1500

# Get a handful of users to make vulnerable
[int32]$VulnerableCount = Get-Random -Minimum 4 -Maximum 11

# Start the misconfiguration of the AD
Write-Host "[+] (Mis)Configuring $((Get-ADDomain).DNSRoot).." -ForegroundColor Green

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

# Randomise Group Memberships
Add-RandomObjectsToGroups 

# Move DC back to the Domain Controllers OU
Set-DCLocation

# Start making the AD vulnerable and keep track of the vulnerable users
Write-Host "[+] Automating ATTACK Vectors.." -ForegroundColor Green

# Primary Attack Vectors ------------------------------------------------------
# Make random number of users roastable, then provide them with passwords which are either weak or in the user description field

# Arrays to house the ADUser objects
$RoastableUsers = @()
$VulnUsers = @()

# ATTACK - Kerberoasting
$RoastableUsers += New-KerberoastableUser -KerbUserCount $([math]::Ceiling($VulnerableCount / 2)) 

# ATTACK - ASREP roasting
$RoastableUsers += New-ASREPUser -ASREPUserCount $([math]::Floor($VulnerableCount / 2)) 

# Shuffle these up and split into two arrays to pass to the password functions
$RoastableUsers = $RoastableUsers | Sort-Object { Get-Random }
$halfCount = [math]::Ceiling($RoastableUsers.Count / 2)
$FirstHalf = $RoastableUsers[0..($halfCount-1)]
$SecondHalf = $RoastableUsers[$halfCount..($RoastableUsers.Count-1)]

# ATTACK - Brute force roastable users
$VulnUsers += Set-WeakPassword -VulnUsers $FirstHalf 

# ATTACK - Plaintext passwords in description field
$VulnUsers += Set-PasswordInDescription -VulnUsers $SecondHalf 

# ATTACK - Pre 2k Computer Account
New-Pre2KComputerAccount 

# ATTACK - Enable Anonymous LDAP Read Access (Only needs to be once per forest)
If ((Get-ADDomain).DistinguishedName -eq (Get-ADRootDSE).rootDomainNamingContext) {
   Enable-AnonymousLDAP
}

# Secondary Attack Vectors ----------------------------------------------------
# Now employ multiple attack vectors on our vulnerable users

# ATTACK - DNS Admin
New-DNSAdmin -VulnUsers $VulnUsers 

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

# ATTACK - Protected Users Bypass
Enable-ProtectedAdmin

# ATTACK - LAPS (available on OS > April 2023). Verbose messages are in the function
If (Get-Command Update-LapsADSchema -ErrorAction SilentlyContinue) {
   Install-LAPS -VulnUsers $VulnUsers
}

# ATTACK - ESC vulnerabilities
try {
   Get-ADObject -Filter { ObjectClass -eq 'certificationAuthority' } -SearchBase "CN=Certification Authorities,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).defaultNamingContext)"
   Set-ESC5 -VulnUsers $VulnUsers 
   Set-ESC7 -VulnUsers $VulnUsers 
} catch {
   Write-Host "    [+] No Certificate Authority on the local domain. Skipping.." -ForegroundColor Yellow
}

# ATTACK - PrintNightmare Vulnerabilities
Enable-PrintNightmare

# Machine Attack Vectors ------------------------------------------------------

# ATTACK - Enable NTLMv1
Enable-NTLMv1

# ATTACK - Disable SMB Signing
Disable-SMBSigning

# ATTACK - Enable SMB Reflection
Enable-Reflection

# Return vulnerable users for cross domain membership attacks
return $VulnUsers