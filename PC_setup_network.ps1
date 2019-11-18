#$ErrorActionPreference = "SilentlyContinue"
########################################################## 
# COMMENT : Выполняет настройку сетевого адаптера на свежеразлитом ПК
# - необходимо существование учетной записи ПК в домене
# - ПК должен быть подключен к сети и иметь актуальную запись DNS  
########################################################### 

$NIC='Ethernet' # Current Network adapter (NIC) name (Ethernet, VC, etc.)
$new_NIC='VC'  # New desired name for NIC
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
Write-Host "Данный скрипт выполняет настройку сетевого адаптера на свежеразлитом ПК"
$brk=0

Function setup_net {
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
$ip=(Get-ADComputer -Identity $comp -Properties 'networkAddress').networkAddress
$sb=[ScriptBlock]::create("
Rename-NetAdapter -Name $NIC -NewName $new_NIC
Set-DnsClientServerAddress -InterfaceAlias $new_NIC -ServerAddresses 10.0.0.4, 10.0.0.14
New-NetIPAddress -InterfaceAlias $new_NIC -AddressFamily IPv4 -IPAddress $ip -PrefixLength 8 -Type Unicast -DefaultGateway 10.0.0.1
")
Invoke-Command -ComputerName $comp -ScriptBlock $sb -AsJob -JobName $comp
if($Error.Count -gt 0){
Write-Host $Error
$Error.Clear()}
else{
Write-Host "ПК $comp успешно" -ForegroundColor Green}
}
else{
Write-Host "ПК $comp недоступен"-ForegroundColor Red }
}
Write-Host "`nподождите, идет сбор результатов"
Start-Sleep -Seconds 20
foreach ($comp in $pc){Get-Job -Name $comp}
}
while ($brk -eq 0) {
$output=setup_net
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}