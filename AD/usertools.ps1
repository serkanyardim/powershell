Get-ADUser -Filter * -Properties DisplayName, SamAccountName, Mail, Title, Department, Enabled | 
    Select-Object DisplayName, SamAccountName, Mail, Title, Department, Enabled |
    Format-Table -AutoSize
