
$brk=0
$base="DC=vc,DC=miet,DC=ru"
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

$spath=Read-Host -Prompt "Enter the source path"
$dpath=Read-Host -Prompt "Enter the destination path ( path on remote PC: C$\Windows\System32)"
#\\vc.miet.ru\space\Install\Images\Disk_D_4k\KFN
foreach ($comp in $pc){
Copy-Item -Path "$spath" -Destination "\\$comp\$dpath" -Recurse -Force
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