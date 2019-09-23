$a=invoke-command -ComputerName 12-30 -ScriptBlock {$acl=get-acl -Path 'C:\Program Files\winpython'
Return $acl
}
invoke-command -ComputerName 13-01 -ArgumentList $a -ScriptBlock {set-acl -Path 'C:\Program Files\winpython' -AclObject $args[0]} 

