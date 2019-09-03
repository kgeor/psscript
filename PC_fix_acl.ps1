
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

$a=invoke-command -ComputerName 12-30 -ScriptBlock {$acl=get-acl -Path 'C:\Program Files\winpython'
Return $acl
}

foreach ($comp in $pc){
Invoke-Command -ComputerName $comp -ArgumentList $a -AsJob -ScriptBlock {
Set-Acl -Path 'C:\Program Files\winpython' -AclObject $args[0]
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