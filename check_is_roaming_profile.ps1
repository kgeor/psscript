Get-ADUser -Filter * -Properties profilepath | where{$_.profilepath -ne $null} | select name, profilepath | sort name
Get-ADUser -SearchBase "OU=MIET,DC=TCS,DC=MIET,DC=RU" -Filter * -Properties ProfilePath |
Set-ADUser -Clear ProfilePath
