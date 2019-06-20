Clear-DnsClientCache
$ErrorActionPreference = "SilentlyContinue"
$nameNIC='Ethernet' # Network adapter name (Ethernet, VC, etc.)
$new_nameNIC='VC'
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

$pc | foreach {if(test-connection -count 1 -computerName $_ -TimeToLive 3 -Quiet){
$ip=(Get-ADComputer -Identity $_ -Properties 'networkAddress').networkAddress
$sb={
Rename-NetAdapter -Name $NIC -NewName $new_nameNIC
$netadapter = Get-NetAdapter -Name $new_nameNIC
Set-DnsClientServerAddress -InterfaceAlias $new_nameNIC -ServerAddresses 10.0.0.4, 10.0.0.14
New-NetIPAddress -InterfaceAlias $new_nameNIC -AddressFamily IPv4 -IPAddress $ip -PrefixLength 8 -Type Unicast -DefaultGateway 10.0.0.1
}
Invoke-Command -ComputerName $_ -ScriptBlock $sb
if($Error.Count -gt 0){$Error}
else{
write "ПК $_ успешно"}
}
else {write "Ошибка. ПК $_ не доступен"}}
Read-Host -Prompt "Press any key to close"