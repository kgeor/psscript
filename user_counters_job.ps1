$classList=@{
'05*'='3105'
'18*'='3118'
'20*'='3120a'
'21*'='3120b'
'12*'='4212a'
'13*'='4212b'
'14*'='4214'
}

#$aud="12*"
foreach ($aud in $classList.Keys){
$sb={
$ErrorActionPreference = "SilentlyContinue"
$ou="OU=StudentsComp,DC=vc,DC=miet,DC=ru"
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
$start=@([datetime]'09:00',[datetime]'10:40',[datetime]'12:50',[datetime]'14:30',[datetime]'16:10',[datetime]'18:20',[datetime]'20:00')
$end=@([datetime]'10:30',[datetime]'12:10',[datetime]'14:10',[datetime]'16:00',[datetime]'17:40',[datetime]'19:50',[datetime]'21:30')
$date=Get-Date 
# Обнуляем и инициализируем переменные
[System.Collections.ArrayList]$pc=@()
[System.Collections.ArrayList]$group=@()
[System.Collections.ArrayList]$final=@()
$username =''
$tutor=''

# Получение списка компьютеров для текущей аудитории #Получение включенных ПК
$apc=(Get-ADComputer -Filter {Name -like $args[0]} -SearchBase "OU=StudentsComp,DC=vc,DC=miet,DC=ru").Name |
ForEach-Object -Process {if(test-connection -count 1 -computerName $_ -TimeToLive 3 -Quiet){
$pc.Add((Get-WMIObject Win32_ComputerSystem -ComputerName $_).Name) }}

# Преподский
$tpc=(Get-ADComputer -Filter {Name -like $args[0]} -SearchBase "OU=Media,OU=StudentsComp,DC=vc,DC=miet,DC=ru").Name

try {
$tutor=(Get-WMIObject -Class Win32_computerSystem -computer $tpc).username -replace '\w+\\(?<user>\w+)', '${user}' | Get-ADUser -Properties "DisplayName"
}
catch {
$tutor = $null    
}  
# Получение текущего пользователя и времени
try {
$username = (Get-WMIObject -Class Win32_computerSystem -computer $pc).username -replace '\w+\\(?<user>\w+)', '${user}'
}
catch {
$username += $null    
}   


$time=Get-Date -Format "dd.MM - HH:mm"

# Определение группы пользователей
foreach ($user in $username){
$group.Add((Get-ADPrincipalGroupMembership $user |where {$_.name -match "-"} | Select-Object -Last 1).name)|Out-Null  #where {$_.name -match "-{1,1}"}).name)
}

if(!$group ){$group.Add('Нет')}
$group|Group-Object | ForEach-Object -Process{$data=New-Object PSObject -Property @{Cntr=''; Group=''}; 
$data.Group=$($_.Name); $data.Cntr=$($_.Count);
$final.Add($data)} | Out-Null 

for ($i=0;$i -le $start.length;$i++){
if(($date -ge $start[$i]) -and ($date -le $end[$i])){
$pair=$i+1
}}

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
$a=$classList[$args[0]]
$worksheet=$Workbook.Worksheets.item($a)
$worksheet.Activate()
$LastRowUsed = $worksheet.UsedRange.Rows.Count
$Row = $worksheet.UsedRange.Rows.Count + 1

# Запись данных в ячейки
$worksheet.Cells.Item($Row,1)=$time
$worksheet.Cells.Item($Row,2)=$pair
$worksheet.Cells.Item($Row,5)=$tutor.DisplayName
$final | ForEach-Object {
$worksheet.Cells.Item($Row,3)=$_.Group
$worksheet.Cells.Item($Row,4)=$_.Cntr
$Row++}

# Сохранить, закрыть и освободить приложение
$Excel.ActiveWorkbook.Save()
$Workbook.Close()
$Excel.Quit()
#[System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Excel) | Out-Null
Remove-Variable -Name Excel 
}
Start-Job -ScriptBlock $sb -ArgumentList $aud -
Get-Job
}
