
$brk=0
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"

Function cp_net{
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
#Invoke-Command -ComputerName $pc -ArgumentList $spath,$dpath -Credential VC\console -ScriptBlock {Copy-Item -Path $args[0] -Destination $args[1]  -Recurse -Force}
foreach ($comp in $pc){
$spath1="\\$comp\d$\"+'$RECYCLE.BIN'
$spath2="\\$comp\n$\"+'$RECYCLE.BIN'
Get-ChildItem -Path $spath1 -Recurse -Force | Remove-Item  -Recurse -Force
Get-ChildItem -Path $spath2 -Recurse -Force | Remove-Item  -Recurse -Force
#Start-Job -Name "$comp-1" -ArgumentList $spath1,$dpath1 -ScriptBlock {Copy-Item -Path $args[0] -Destination $args[1] -Recurse -Force}
if($Error.Count -gt 0){ 
Write-Host $Error -ForegroundColor Red
$Error.Clear()}
else{
Write-Host "ПК $comp успешно" -ForegroundColor Green}
}}

while ($brk -eq 0) {
$output=cp_net
write ($output)
$brk=Read-Host -Prompt "Press 0 to repeat, any other to close"
}