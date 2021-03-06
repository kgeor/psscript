﻿$ErrorActionPreference = "SilentlyContinue"
########################################################## 
# COMMENT : Скрипт перезагружает/выключает ПК
# - необходимо существование учетной записи для ПК в домене
########################################################### 

$brk=0
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
Function sr {
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
$rsbcn = Read-Host -Prompt "Введите 1 для перезагрузки, 2 для выключения"

foreach ($comp in $pc){
if(Test-Connection -ComputerName $comp -Count 1 -Quiet){ 
Write-Host "ПК $comp онлайн" -BackgroundColor DarkGreen
if ($rsbcn -eq 1) {Restart-Computer -ComputerName $comp -Force}
else {Stop-Computer -ComputerName $comp -Force}
 
if($Error.Count -gt 0){
Write-Host $Error
$Error.Clear()}
else{
Write-Host "ПК $comp успешно" -ForegroundColor Green}
}
else{
Write-Host "ПК $comp недоступен"-ForegroundColor Red }
}}

while ($brk -eq 0) {
$output=sr
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}