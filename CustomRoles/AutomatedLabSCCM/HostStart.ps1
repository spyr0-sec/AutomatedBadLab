param(
    [Parameter(Mandatory)]
    [string]$ComputerName
)

# Import Lab
Import-Lab -Name $data.Name -NoValidation -NoDisplay

# Take a snapshot of the CM server before we start making changes
Write-ScreenInfo "Creating snapshot of base CM server"
Checkpoint-LabVM -ComputerName $ComputerName -SnapshotName "Pre-AutomatedLabSCCM"

# Create the vulnerable AD accounts on the Domain Controller
$CMServer = Get-LabVM -ComputerName $ComputerName
$DomainController = Get-LabVM -Role RootDC | Where-Object { $_.DomainName -eq $CMServer.DomainName }

Invoke-LabCommand -ComputerName $DomainController -ActivityName "Creating AutomatedLabSCCM AD Accounts" -ScriptBlock {

    # Create the Network Access Account (CRED-2, CRED-3, CRED-5)
    $NAA = New-ADUser -Name "SCCM_NAA" -SamAccountName "SCCM_NAA" -AccountPassword (ConvertTo-SecureString "Somepass1" -AsPlainText -Force) -Enabled $true -PasswordNeverExpires $true -EA SilentlyContinue

    # Create the Task Sequence "run as" account (CRED-3, CRED-4)
    $TSAccount = New-ADUser -Name "SCCM_TS_Account" -SamAccountName "SCCM_TS_Account" -AccountPassword (ConvertTo-SecureString "Somepass2" -AsPlainText -Force) -Enabled $true -PasswordNeverExpires $true -EA SilentlyContinue

    # Create a lazy admin account (various)
    $LazyAdmin = New-ADUser -Name "SCCM_LazyAdmin" -SamAccountName "SCCM_LazyAdmin" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true -PasswordNeverExpires $true -EA SilentlyContinue

}

Write-ScreenInfo "Provisioning SCCM via AutomatedLabSCCM"
