
#$ErrorActionPreference = "SilentlyContinue"
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
$brk=0

Function set_reg {
$basebcn = Read-Host -Prompt "Текущая база поиска: $base.`nНажмите Enter, чтобы продолжить работу с текущей базой или введите '1' для смены"
if($basebcn -eq "1"){
$base = Read-Host -Prompt "Укажите новую базу поиска в формате LDAP"
}
$bcn = Read-Host -Prompt "Введите '1' для работы с целым классом или '2' для работы с одним ПК"
if($bcn -eq "1"){
$aud = Read-Host -Prompt "Введите общую часть имен ПК класса (05,20,12)"
$aud+='*'
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $base).Name
}
if($bcn -eq "2"){
$pc = Read-Host -Prompt "Введите имя ПК"
}
Write-Host "`nplease wait, we collecting results"
$pth="HKCU:\Software\Unique IC's\"
foreach ($comp in $pc){

Invoke-Command -ComputerName $comp -ArgumentList $pth -ScriptBlock {if(Test-Path -Path $args[0]){Remove-Item -Path $args[0] -Recurse}}

if($Error.Count -gt 0){ Write-Host $Error}
else{
Write-Host "ПК $comp успешно"}

}
}

while ($brk -eq 0){
$output=set_reg
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}