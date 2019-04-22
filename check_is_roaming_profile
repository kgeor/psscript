Get-ADUser -Filter * -Properties profilepath | where{$_.profilepath -ne $null} | select name, profilepath | sort name
