#$ErrorActionPreference = "SilentlyContinue"
$brk=0
$base="DC=vc,DC=miet,DC=ru"
Function set_net {
$bcn = Read-Host -Prompt "Введите 'a' для задания аудитории или 'p' для задания имени ПК"
if($bcn -eq "a"){
$aud = Read-Host -Prompt "Введите номер аудитории в формате двух последних цифр"
$aud+='*'
}
if($bcn -eq "p"){
$pc = Read-Host -Prompt "Введите имя ПК"
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