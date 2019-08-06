﻿Clear-DnsClientCache
#$ErrorActionPreference = "SilentlyContinue"
$NIC='Ethernet' # Current Network adapter (NIC) name (Ethernet, VC, etc.)
$new_NIC='VC'  # New desired name for NIC
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
$brk=0

Function setup_net {
$basebcn = Read-Host -Prompt "Current search base: $base.`nPress enter to continue with this or Enter '1' to change search base"
if($basebcn -eq "1"){
$base = Read-Host -Prompt "Enter the new search base in LDAP format"}
$bcn = Read-Host -Prompt "Enter the 'a' for work with whole class or the 'p' for one certain PC"
if($bcn -eq "a"){
$aud = Read-Host -Prompt "Enter common part of PC's names (two last digits in class number)"
$aud+='*'
}
if($bcn -eq "p"){
$pc = Read-Host -Prompt "Enter the PC name"
}

if($pc -eq $null){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $base).Name
}
Write-Host "`nplease wait, we collecting results"

foreach ($comp in $pc){
$ip=(Get-ADComputer -Identity $comp -Properties 'networkAddress').networkAddress
$sb=[ScriptBlock]::create("
Rename-NetAdapter -Name $NIC -NewName $new_NIC
Set-DnsClientServerAddress -InterfaceAlias $new_NIC -ServerAddresses 10.0.0.4, 10.0.0.14
New-NetIPAddress -InterfaceAlias $new_NIC -AddressFamily IPv4 -IPAddress $ip -PrefixLength 8 -Type Unicast -DefaultGateway 10.0.0.1
")
Invoke-Command -ComputerName $comp -ScriptBlock $sb -AsJob -JobName $comp
}
Start-Sleep -Seconds 20
foreach ($comp in $pc){Get-Job -Name $comp}
}

while ($brk -eq 0) {
$output=setup_net
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}