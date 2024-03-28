Function Enable-GuestUser {
    Write-Log -Message "Enabling $($(Get-ADDomain).DNSRoot)\Guest Account"
    Enable-ADAccount -Identity Guest
}
