
$brk=0
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"

Function cp_net {
$basebcn = Read-Host -Prompt "Current search base: $base.`nPress enter to continue with this or Enter '1' to change search base"
if($basebcn -eq "1"){
$base = Read-Host -Prompt "Enter the new search base in LDAP format"}
$bcn = Read-Host -Prompt "Enter the 'a' for work with whole class or the 'p' for one certain PC"
if($bcn -eq "a"){
$aud = Read-Host -Prompt "Enter common part of PC's names (two last digits in class number)"
$aud+='*'
}
if($bcn -eq "p"){
$pc = Read-Host -Prompt "Enter the PC name"
}
if($null -eq $pc){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $base).Name
}

$spath1="\\12-30\c$\Program Files\winpython"
$spath2="\\12-30\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\winpython"
#c$\Program Files\winpython
#"\\12-30\c$\Program Files (x86)\eclipse"
#\\12-30\c$\12-30\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\eclipse


#Invoke-Command -ComputerName $pc -ArgumentList $spath,$dpath -Credential VC\console -ScriptBlock {Copy-Item -Path $args[0] -Destination $args[1]  -Recurse -Force}
foreach ($comp in $pc){
if ($comp -ne '12-30'){
$dpath1="\\$comp\c$\Program Files"
$dpath2="\\$comp\c$\ProgramData\Microsoft\Windows\Start Menu\Programs"
Start-Job -Name "$comp-1" -ArgumentList $spath1,$dpath1 -ScriptBlock {Copy-Item -Path $args[0] -Destination $args[1] -Recurse -Force}
Start-Job -Name "$comp-2" -ArgumentList $spath2,$dpath2 -ScriptBlock {Copy-Item -Path $args[0] -Destination $args[1] -Recurse -Force}
#.\Robocopy.exe $spath $dpath $ro.split(' ')
#Copy-Item -Path $spath -Destination $dpath  -Recurse -Force
#Copy-Item -Path "\\21-11\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\Eclipse 4.5.2.lnk" -Destination "\\$comp\c$\ProgramData\Microsoft\Windows\Start Menu\Programs\Eclipse 4.5.2.lnk"  -Force
###
}
if($Error.Count -gt 0){ 
Write-Host $Error}
else{
Write-Host "ПК $comp успешно"}
}}

while ($brk -eq 0) {
$output=cp_net
write ($output)
$brk=Read-Host -Prompt "Press 0 to repeat, any other to close"

}