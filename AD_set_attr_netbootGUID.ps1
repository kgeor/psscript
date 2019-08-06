#$ErrorActionPreference = "SilentlyContinue"
$brk=0
$base="DC=vc,DC=miet,DC=ru"
Function set_bootid {
$basebcn = Read-Host -Prompt "Current search base: $base.`nPress enter to continue with this or Enter '1' to change search base"
if($basebcn -eq "1"){
$base = Read-Host -Prompt "Enter the new search base in LDAP format"}
$bcn = Read-Host -Prompt "Enter the 'a' for work with whole class or the 'p' for one certain PC"
if($bcn -eq "a"){
$aud = Read-Host -Prompt "Enter common part of PC's names (two last digits in class number)"
$aud+='*'
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $base).Name
}
if($bcn -eq "p"){
$pc = Read-Host -Prompt "Enter the PC name"
}

foreach ($comp in $pc){
$s=Get-WmiObject -ClassName Win32_NetworkAdapterConfiguration -ComputerName $comp| Where-Object {$_.DefaultIPGateway -eq '10.0.0.1'} | Select-Object -Property MACAddress
$mac=$s[0].MACAddress.Replace(':', '')
[guid]$nbGUID = "00000000-0000-0000-0000-$mac"
Set-ADComputer -Identity $comp -Replace @{'netbootGUID'=$nbGUID}
if($Error.Count -gt 0){ Return $Error}
else{
Return "ПК $comp успешно"}
}}

while ($brk -eq 0) {
$output=set_bootid
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}