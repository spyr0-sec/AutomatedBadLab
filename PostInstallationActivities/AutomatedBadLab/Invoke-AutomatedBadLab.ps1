# Import all functions from AutomatedBadLab Module
Import-Module -Name (Join-Path $PSScriptRoot 'AutomatedBadLab.psm1') -Force

# AD Object type quantities
[int32]$UserCount = 1000
[int32]$GroupCount = 100
[int32]$ComputerCount = 1500

# Get a handful of users to make vulnerable
[int32]$VulnerableCount = Get-Random -Minimum 4 -Maximum 11

# Weaken AD Password Policies
Set-WeakPasswordPolicy

# Organizational Unit Creation and structure
New-BLOUStructure

# User Creation
New-BLUser -UserCount $UserCount -Verbose -ErrorAction SilentlyContinue

# Group Creation
New-BLGroup -GroupCount $GroupCount -Verbose -ErrorAction SilentlyContinue

# Computer Creation
New-BLComputer -ComputerCount $ComputerCount -Verbose -ErrorAction SilentlyContinue

# Randomise ACLs
Write-Host "[+] TODO! Creating Random Permissions.." -ForegroundColor Green
  
# Randomise Group Memberships
Add-RandomObjectsToGroups 

# Start making the AD vulnerable and keep track of the vulnerable users
Write-Host "[+] Automating ATTACK Vectors.." -ForegroundColor Green

# Primary Attack Vectors ------------------------------------------------------
# Make random number of users roastable, then provide them with passwords which are either weak or in the user description field

# These arrays contain samAccountNames, ADUsers will be resolved in the functions
$RoastableUsers = @()
$VulnUsers = @()

# ATTACK - Kerberoasting
$RoastableUsers += New-KerberoastableUser -KerbUserCount $([math]::Ceiling($VulnerableCount / 2)) -Verbose

# ATTACK - ASREP roasting
$RoastableUsers += New-ASREPUser -ASREPUserCount $([math]::Floor($VulnerableCount / 2)) -Verbose

# Shuffle these up and split into two arrays to pass to the password functions
$RoastableUsers = $RoastableUsers | Sort-Object { Get-Random }
$halfCount = [math]::Ceiling($RoastableUsers.Count / 2)
$FirstHalf = $RoastableUsers[0..($halfCount-1)]
$SecondHalf = $RoastableUsers[$halfCount..($RoastableUsers.Count-1)]

# ATTACK - Brute force roastable users
$VulnUsers += Set-WeakPassword -VulnUsers $FirstHalf -Verbose

# ATTACK - Plaintext passwords in description field
$VulnUsers += Set-PasswordInDescription -VulnUsers $SecondHalf -Verbose

# ATTACK - Pre 2k Computer Account
New-Pre2KComputerAccount -Verbose

# ATTACK - Enable Anonymous LDAP Read Access
Enable-AnonymousLDAP

# ATTACK - Enable NTLMv1
Enable-NTLMv1

# Secondary Attack Vectors ----------------------------------------------------
# Now employ multiple attack vectors on our vulnerable users

# ATTACK - DNS Admin
New-DNSAdmin -VulnUsers $VulnUsers -Verbose

# ATTACK - Weak Kerberos Encryption
Enable-AllKerbEncryptionTypes 
New-DESKerberosUser -VulnUsers $VulnUsers -Verbose

# ATTACK - Reverable Password Encryption
New-ReversablePasswordUser -VulnUsers $VulnUsers -Verbose

# ATTACK - Group Managed Service Accounts (gMSA)
New-gMSA -VulnUsers $VulnUsers -Verbose

# ATTACK - Group Policy Passwords
Set-AdministratorPassword -Verbose

# ATTACK - DACL Attacks
New-DACLAttacks -VulnUsers $VulnUsers -Verbose

# ATTACK - Owner Attacks
New-Owner -VulnUsers $VulnUsers -Verbose

# ATTACK - DCSync Attack
New-DCSyncUser -VulnUsers $VulnUsers -Verbose

# ATTACK - Resource Based Constrained Delegation Attack
New-RBCDUser -VulnUsers $VulnUsers -Verbose

# ATTACK - LAPS. Verbose messages are in the function
Install-LAPS -VulnUsers $VulnUsers

# ATTACK - ESC vulnerabilities
If (Get-ADObject -Filter { ObjectClass -eq 'certificationAuthority' } -SearchBase "CN=Certification Authorities,CN=Public Key Services,CN=Services,$((Get-ADRootDSE).configurationNamingContext)") {
   Set-ESC5 -VulnUsers $VulnUsers -Verbose
   Set-ESC7 -VulnUsers $VulnUsers -Verbose
}
