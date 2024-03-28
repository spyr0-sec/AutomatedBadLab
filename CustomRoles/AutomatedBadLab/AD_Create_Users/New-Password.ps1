Function New-Password {

    Param (
        [int]$length = 22
    )

    $lowercase = 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()
    $uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()
    $numbers = '0123456789'.ToCharArray()
    $specials = '!@#$%^&*()-_=+[]{}|;:,.<>?/'.ToCharArray()

    # Start the password with one character from each category
    $passwordArray = @(
        ($lowercase | Get-Random -Count 1),
        ($uppercase | Get-Random -Count 1),
        ($numbers | Get-Random -Count 1),
        ($specials | Get-Random -Count 1)
    )

    # Add remaining characters
    $allChars = $lowercase + $uppercase + $numbers + $specials
    $remainingLength = $length - $passwordArray.Length

    for ($i = 0; $i -lt $remainingLength; $i++) {
        $passwordArray += $allChars | Get-Random -Count 1
    }

    # Shuffle the characters
    $shuffledPassword = $passwordArray | Get-Random -Count $length

    # Return as string
    return (-join $shuffledPassword)
}