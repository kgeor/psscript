$ErrorActionPreference = "SilentlyContinue"
########################################################## 
# COMMENT : Выполняет ping 
# - необходимо существование учетной записи для ПК в домене
########################################################### 

$brk=0
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
Write-Host "Данный скрипт выполняет проверку доступности ПК по сети"
Function pi {
$basebcn = Read-Host -Prompt "Текущая база поиска: $base.`nНажмите Enter, чтобы продолжить работу с текущей базой или введите '1' для смены"
if($basebcn -eq "1"){
$base = Read-Host -Prompt ""}
$bcn = Read-Host -Prompt "Введите '1' для работы с целым классом или '2' для работы с одним ПК"
if($bcn -eq "1"){
$aud = Read-Host -Prompt "Введите общую часть имен ПК класса (05,20,12)"
$aud+='*'
}
if($bcn -eq "2"){
$pc = Read-Host -Prompt "Введите имя ПК"
}

if($null -eq $pc){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $base).Name
}

foreach ($comp in $pc){
 
if(Test-Connection -ComputerName $comp -Count 1 -Quiet){ 
Write-Host "ПК $comp онлайн"}
else{
Write-Host "ПК $comp недоступен"}
}}

while ($brk -eq 0) {
$output=pi
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}