$ErrorActionPreference = "SilentlyContinue"
########################################################## 
# COMMENT : Заполняет атрибут networkAddress ПК в домене, необходимо для скрипта
# настройки сети PC_setup_neTwork
# - необходимо существование учетной записи для ПК в домене
# - адрес формируется на основе запроса к DNS по имени ПК 
########################################################### 

$brk=0
$base="DC=vc,DC=miet,DC=ru"
Write-Host "Данный скрипт заполняет атрибут networkAddress учетной записи ПК в домене"
Function set_net {
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

foreach ($comp in $pc){
if(Test-Connection -ComputerName $comp -Count 1 -Quiet){ 
Write-Host "ПК $comp онлайн" -BackgroundColor DarkGreen
$ip=[System.Net.DNS]::GetHostAddresses($comp).IPAddressToString
Set-ADComputer -Identity $comp -Replace @{'networkAddress'=$ip}
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
$output=set_net
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}