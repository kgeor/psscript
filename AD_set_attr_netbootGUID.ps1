$ErrorActionPreference = "SilentlyContinue"
########################################################## 
# COMMENT : Заполняет атрибут netbootGUID ПК в домене, необходимо для подхватывания
# имени и членства в домене при разливке
# - необходимо существование учетной записи для ПК в домене
# - GUID формируется на основе MAC-адреса (скрипт получает его wmi запросом) 
########################################################### 

$brk=0
$base="DC=vc,DC=miet,DC=ru"
Write-Host "Данный скрипт заполняет атрибут netbootGUID учетной записи ПК в домене"
Function set_bootid {
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
$s=Get-WmiObject -ClassName Win32_NetworkAdapterConfiguration -ComputerName $comp| Where-Object {$_.DefaultIPGateway -eq '10.0.0.1'} | Select-Object -Property MACAddress
$mac=$s[0].MACAddress.Replace(':', '')
[guid]$nbGUID = "00000000-0000-0000-0000-$mac"
Set-ADComputer -Identity $comp -Replace @{'netbootGUID'=$nbGUID}
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
$output=set_bootid
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}