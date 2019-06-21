$ErrorActionPreference = "SilentlyContinue"
$bcn = Read-Host -Prompt "Введите 'a' для задания аудитории или 'p' для задания имени ПК"
if($bcn -eq "a"){
$aud = Read-Host -Prompt "Введите номер аудитории в формате двух последних цифр"
$aud+='*'
}
if($bcn -eq "p"){
$pc = Read-Host -Prompt "Введите имя ПК"
}

if($null -eq $pc){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase "DC=vc,DC=miet,DC=ru").Name
}

foreach ($comp in $pc){
    if(test-connection -count 1 -computerName $comp -TimeToLive 3 -Quiet){
$s=Get-WmiObject -ClassName Win32_NetworkAdapterConfiguration -ComputerName $comp| 
Where-Object {$comp.DefaultIPGateway -eq '10.0.0.1'} | Select-Object -Property MACAddress
$mac=$s[0].MACAddress.Replace(':', '')
[guid]$nbGUID = "00000000-0000-0000-0000-$mac"
Set-ADComputer -Identity $comp -Replace @{'netbootGUID'=$nbGUID}
if($Error.Count -gt 0){$Error}
else{
write "ПК $comp успешно"}
}
else {write "Ошибка. ПК $comp не доступен"}}
Read-Host -Prompt "Press any key to close"