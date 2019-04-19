$ErrorActionPreference = "SilentlyContinue"
#$ou="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
$month=Get-Date -Format "MM-yyyy"
$fpath="C:\Users\kgeor.VC\Desktop\WORK\$month.xlsx"
$tpath="C:\count_template.xlsx"
$classList=@{
'05*'='3105'
'18*'='3118'
'20*'='3120a'
'21*'='3120b'
'12*'='4212a'
'13*'='4212b'
'14*'='4214'
}
# Границы пар и текущее время для сравнения по интервалам
$start=@([datetime]'09:00',[datetime]'10:40',[datetime]'12:50',[datetime]'14:30',[datetime]'16:10',[datetime]'18:20',[datetime]'20:00')
$end=@([datetime]'10:30',[datetime]'12:10',[datetime]'14:10',[datetime]'16:00',[datetime]'17:40',[datetime]'19:50',[datetime]'21:30')
$date=Get-Date 

#$aud="18*"
foreach ($aud in $classList.Keys){
# Обнуляем и инициализируем переменные
[System.Collections.ArrayList]$pc=@()
[System.Collections.ArrayList]$group=@()
[System.Collections.ArrayList]$final=@()
$username=''
$tutor=''

# Получение списка компьютеров для текущей аудитории #Получение включенных ПК
(Get-ADComputer -Filter {Name -like $aud} -SearchBase "OU=StudentsComp,DC=vc,DC=miet,DC=ru").Name |
ForEach-Object -Process {if(test-connection -count 1 -computerName $_ -TimeToLive 3 -Quiet){
$pc.Add((Get-WMIObject Win32_ComputerSystem -ComputerName $_).Name) }} | Out-Null

# Преподский
$tpc=(Get-ADComputer -Filter {Name -like $aud} -SearchBase "OU=Media,OU=StudentsComp,DC=vc,DC=miet,DC=ru").Name
$tutor=(Get-WMIObject -Class Win32_computerSystem -computer $tpc).username -replace '\w+\\(?<user>\w+)', '${user}' | Get-ADUser -Properties "DisplayName"

# Получение текущего пользователя и времени
$username = (Get-WMIObject -Class Win32_computerSystem -computer $pc).username -replace '\w+\\(?<user>\w+)', '${user}'
# Удаление $null из массива
$username=$username | Where-Object {$_}

$time=Get-Date -Format "dd.MM - HH:mm"

# Определение группы пользователей
foreach ($user='r10015818' in $username){
    $gr=$null
    $gr=(Get-ADPrincipalGroupMembership $user | Where-Object {$_.name -match "-[1-4]"} | Select-Object -Last 1).name
if($null -ne $gr){
    $group.Add($gr) | Out-Null
}
else {
if($user -ne $tutor.Name){
    $group.Add($user) | Out-Null}
}}

if(!$group ){$group.Add('Нет')}

$group | Group-Object | ForEach-Object -Process{$data=New-Object PSObject -Property @{Cntr=''; Group=''}; 
$data.Group=$($_.Name); $data.Cntr=$($_.Count);
$final.Add($data)} | Out-Null 

for ($i=0;$i -le $start.length;$i++){
if(($date -ge $start[$i]) -and ($date -le $end[$i])){
    $pair=$i+1
}}

if($null -ne $tutor){
$active_users=$username.Count-1
}
else{
$active_users=$username.Count
}

### Запись данных в Excel
# Создаём объект Excel
$Excel = New-Object -ComObject Excel.Application

# Делаем его видимым
#$Excel.Visible = $true

# Открываем файл, если его нет, создаем из шаблона
try{
$Workbook = $Excel.Workbooks.Open($fpath)}
catch{
$Workbook = $Excel.Workbooks.Open($tpath)
$Excel.ActiveWorkbook.SaveAs($fpath)
}
# Переход на нужный лист и определение первой незаполненной строки
$worksheet=$Workbook.Worksheets.item($classList[$aud])
$worksheet.Activate()
$Row = $worksheet.UsedRange.Rows.Count + 1

# Запись данных в ячейки
$worksheet.Cells.Item($Row,1)=$time
$worksheet.Cells.Item($Row,2)=$pair
$worksheet.Cells.Item($Row,5)=$tutor.DisplayName
$worksheet.Cells.Item($Row,6)=$pc.Count
$worksheet.Cells.Item($Row,7)=$active_users
$final | ForEach-Object {
$worksheet.Cells.Item($Row,3)=$_.Group
$worksheet.Cells.Item($Row,4)=$_.Cntr
$Row++}

# Сохранить, закрыть и освободить приложение
$Excel.ActiveWorkbook.Save()
$Workbook.Close()
$Excel.Quit()
#[System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
}
Start-Sleep 3
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
exit
