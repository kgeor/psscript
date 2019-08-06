#$ErrorActionPreference = "SilentlyContinue"
$brk=0
$base="DC=vc,DC=miet,DC=ru"
Function set_net {
$basebcn = Read-Host -Prompt "Current search base: $base.`nPress enter to continue with this or Enter '1' to change search base"
if($basebcn -eq "1"){
$base = Read-Host -Prompt "Enter the new search base in LDAP format"}
$bcn = Read-Host -Prompt "EEnter the 'a' for work with whole class or the 'p' for one certain PC"
if($bcn -eq "a"){
$aud = Read-Host -Prompt "Enter common part of PC's names (two last digits in class number)"
$aud+='*'
}
if($bcn -eq "p"){
$pc = Read-Host -Prompt "Enter the PC name"
}

if($null -eq $pc){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $base).Name
}

foreach ($comp in $pc){
$ip=[System.Net.DNS]::GetHostAddresses($comp).IPAddressToString
Set-ADComputer -Identity $comp -Replace @{'networkAddress'=$ip}
if($Error.Count -gt 0){ Return $Error}
else{
Return "ПК $comp успешно"}
}}

while ($brk -eq 0) {
$output=set_net
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}