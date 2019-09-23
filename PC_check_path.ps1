
#$ErrorActionPreference = "SilentlyContinue"
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
$brk=0

Function check_path {
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

if($pc -eq $null){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $base).Name
}
Write-Host "`nplease wait, we collecting results"
$pth="C:\Users\Public\Desktop\AvoLayout v2.04.lnk"
foreach ($comp in $pc){
if(Test-Connection -ComputerName $comp -Count 1 -Quiet){ 
Write-Host "ПК $comp онлайн" -BackgroundColor DarkGreen
$b=Invoke-Command -ComputerName $comp -ArgumentList $pth -ScriptBlock {if(Test-Path -Path $args[0]){Return $true}}
if($b) {Write-Host "exist on $comp " -ForegroundColor Cyan -BackgroundColor DarkBlue}
else {Write-Host "need to install on $comp" -ForegroundColor Red}

if($Error.Count -gt 0){
Write-Host $Error
$Error.Clear()}
else{
Write-Host "ПК $comp успешно" -ForegroundColor Green}
}
else{
Write-Host "ПК $comp недоступен"-ForegroundColor Red }

}
}

while ($brk -eq 0){
$output=check_path
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}