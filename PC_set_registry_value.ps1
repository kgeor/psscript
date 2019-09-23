
#$ErrorActionPreference = "SilentlyContinue"
$base="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
$brk=0

Function set_reg {
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

if($pc -eq $null){
$pc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase $base).Name
}
Write-Host "`nplease wait, we collecting results"
$pth="HKCU:\Software\Unique IC's\"
foreach ($comp in $pc){

Invoke-Command -ComputerName $comp -ArgumentList $pth -ScriptBlock {if(Test-Path -Path $args[0]){Remove-Item -Path $args[0] -Recurse}}

if($Error.Count -gt 0){ Write-Host $Error}
else{
Write-Host "ПК $comp успешно"}

}
}

while ($brk -eq 0){
$output=set_reg
write ($output)
$brk=Read-Host -Prompt "Press 0 to continue, any other to close"
}