$ErrorActionPreference = "SilentlyContinue"
write "-----Для применения изменений, внесенных скриптом, не забудь перезагрузить ПК!-----"
write ""
$bcn = Read-Host -Prompt "Введите 'a' для задания аудитории или 'p' для задания имени ПК"
if($bcn -eq "a"){
$aud = Read-Host -Prompt "Введите номер аудитории в формате двух последних цифр"
$aud+='*'
}
if($bcn -eq "p"){
$pc = Read-Host -Prompt "Введите имя ПК"
}

if(($pc -eq $null) -and ($aud -ne $null)){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase "DC=vc,DC=miet,DC=ru").Name
}

$sb = {
cmd.exe /c "reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Csc\Parameters /v FormatDatabase /t REG_DWORD /d 1 /f "| Out-Null;
if($Error.Count -gt 0){$Error}}

$pc | foreach {if(test-connection -count 1 -computerName $_ -TimeToLive 3 -Quiet){
Invoke-Command -ComputerName $_ -ScriptBlock $sb
Write-Host "ПК $_ успешно"
}
else {write "Ошибка. ПК $_ не доступен"}}
$rb = Read-Host -Prompt "Введите 'y' чтобы перезагрузить ПК, иначе оставьте пустым"
if($rb -eq "y"){Restart-Computer -ComputerName $pc}
Read-Host -Prompt "Press any key to close"