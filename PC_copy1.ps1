﻿
$brk=0
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"

Function cp_net {
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

$spath1="\\12-30\c$\Program Files\winpython"
$spath2="\\12-30\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\winpython"
#c$\Program Files\winpython
#"\\12-30\c$\Program Files (x86)\eclipse"
#\\12-30\c$\12-30\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\eclipse


#Invoke-Command -ComputerName $pc -ArgumentList $spath,$dpath -Credential VC\console -ScriptBlock {Copy-Item -Path $args[0] -Destination $args[1]  -Recurse -Force}
foreach ($comp in $pc){
if ($comp -ne '12-30'){
$dpath1="\\$comp\c$\Program Files"
$dpath2="\\$comp\c$\ProgramData\Microsoft\Windows\Start Menu\Programs"
Start-Job -Name "$comp-1" -ArgumentList $spath1,$dpath1 -ScriptBlock {Copy-Item -Path $args[0] -Destination $args[1] -Recurse -Force}
Start-Job -Name "$comp-2" -ArgumentList $spath2,$dpath2 -ScriptBlock {Copy-Item -Path $args[0] -Destination $args[1] -Recurse -Force}
#.\Robocopy.exe $spath $dpath $ro.split(' ')
#Copy-Item -Path $spath -Destination $dpath  -Recurse -Force
#Copy-Item -Path "\\21-11\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\Eclipse 4.5.2.lnk" -Destination "\\$comp\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\Eclipse 4.5.2.lnk"  -Force
###
}
if($Error.Count -gt 0){ 
Write-Host $Error}
else{
Write-Host "ПК $comp успешно"}
}}

while ($brk -eq 0) {
$output=cp_net
write ($output)
$brk=Read-Host -Prompt "Press 0 to repeat, any other to close"

}