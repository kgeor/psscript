$ErrorActionPreference = "SilentlyContinue"
$aud='18-*'
$apc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase "OU=StudentsComp,DC=vc,DC=miet,DC=ru").Name 

$pc=(Get-WMIObject Win32_ComputerSystem -ComputerName $apc).Name 


#Perform chkdsk for %systemdrive%
$sb={
Get-WMIObject Win32_ComputerSystem | Select-Object -ExpandProperty name;
$null=cmd.exe /c "echo y|chkdsk %systemdrive% /f /r";
if($Error.Count -gt 0){$Error}}

Invoke-Command -ComputerName $pc -ScriptBlock $sb

#Check PS version
$test={$PSVersionTable.PSVersion
Invoke-Command -ComputerName $pc -ScriptBlock $test
}

### Update installing
#LOCAL Path for update files
$HotfixPath = "C:\tmp\KB3191566-x64.msu"

#Copy update files from LOCAL to remote path
$pc | foreach {
$remotePath = "\\$_\c$\tmp\"
if(!(Test-Path $remotePath))
    {
        $null=New-Item -ItemType Directory -Force -Path $remotePath
    }
Copy-Item $Hotfixpath -Destination $remotePath -Force;
if($Error.Count -gt 0){$Error}
}
#Unpack and install all updates(should be enumerated)
$sb2={
Start-Process -FilePath 'wusa.exe' -ArgumentList "C:\tmp\KB3191566-x64.msu /extract:C:\tmp" -Wait -Passthru;
Start-Sleep -Seconds 5;
Start-Process -FilePath 'dism.exe' -ArgumentList "/online /add-package /PackagePath:C:\tmp\WSUSSCAN.cab /PackagePath:C:\tmp\Windows6.1-KB2809215-x64.cab /PackagePath:C:\tmp\Windows6.1-KB2872035-x64.cab /PackagePath:C:\tmp\Windows6.1-KB2872047-x64.cab /PackagePath:C:\tmp\Windows6.1-KB3033929-x64.cab /PackagePath:C:\tmp\Windows6.1-KB3191566-x64.cab /IgnoreCheck /quiet" -Wait -PassThru;
}
Invoke-Command -ComputerName $pc -ScriptBlock $sb2

#Remove copying files and get events or chkdsk, check PS Version
$pc | foreach {
$remotePath = "\\$_\c$\tmp\"
Remove-Item $remotePath -Force -Recurse
Get-WinEvent -ComputerName $_ -FilterHashtable @{LogName='Application';ID='1001'}|
Where-Object -Property Message -Match 'chkdsk' | Format-List -Property MachineName, Message}

Get-WinEvent -ComputerName $pc -FilterHashtable @{LogName='Application';ID='1001'}

#Stop PC
if($Error.Count -gt 0){$Error}
Stop-Computer -ComputerName $pc -Force


#Get logs
$pc | foreach {Get-WinEvent -ComputerName $_ -FilterHashtable @{LogName='Application';ID='1001'}|
Where-Object -Property Message -Match 'chkdsk' | Format-List -Property MachineName, Message}

