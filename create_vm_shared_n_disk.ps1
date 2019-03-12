$ErrorActionPreference = "SilentlyContinue"
$aud= Read-Host -Prompt 'Введите номер аудитории в формате двух последних цифр (12 для 4212а, 13 для 4212б и тп)'
$aud+='*'
$apc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase "OU=StudentsComp,DC=vc,DC=miet,DC=ru").Name 
$pc=(Get-WMIObject Win32_ComputerSystem -ComputerName $apc).Name 


#Perform chkdsk for %systemdrive%
$sb={
$path = "N:\VM";
Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty name;
if(!(test-path $path)){New-Item -Path $path -ItemType directory};
cmd.exe /c "net share vm$=N:\VM /GRANT:VCUsers,CHANGE"| Out-Null;
if($Error.Count -gt 0){$Error}}

Invoke-Command -ComputerName $pc -ScriptBlock $sb
Read-Host -Prompt 'press any key to close'