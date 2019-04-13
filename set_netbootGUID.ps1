$pc=''
$aud=''
$path=''
$bcn = Read-Host -Prompt "Введите 'a' для задания аудитории или 'p' для задания имени ПК"
if($bcn -eq "a"){
$aud = Read-Host -Prompt "Введите номер аудитории в формате двух последних цифр"
$aud+='*'
$path = Read-Host -Prompt "Укажите полный путь до OU/CN с ПК. Оставьте пустым для поиска по умолчанию в 
OU=StudentsComp,DC=vc,DC=miet,DC=ru"
if($path -eq ''){$path = "OU=StudentsComp,DC=vc,DC=miet,DC=ru"}
}
if($bcn -eq "p"){
$pc=(Get-ADComputer (Read-Host -Prompt "Введите имя ПК")).Name
}

if($pc -eq ''){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $path).Name
}

$pc | foreach {if(test-connection -count 1 -computerName $_ -TimeToLive 3 -Quiet){
$s=Get-WmiObject -ClassName Win32_NetworkAdapterConfiguration -ComputerName $_| 
Where-Object {$_.DefaultIPGateway -eq '10.0.0.1'} | Select-Object -Property MACAddress
$mac=$s[0].MACAddress.Replace(':', '')
[guid]$nbGUID = "00000000-0000-0000-0000-$mac"
Set-ADComputer -Identity $_ -Replace @{'netbootGUID'=$nbGUID}
write "ПК $_ успешно"
}
else {write "Ошибка. ПК $_ не доступен"}}
Read-Host -Prompt "Press any key to close"