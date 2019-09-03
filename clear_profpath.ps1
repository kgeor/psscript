Get-ADUser -SearchBase "OU=Students,DC=VC,DC=MIET,DC=RU" -Filter * -Properties ProfilePath |
Set-ADUser -Clear ProfilePath