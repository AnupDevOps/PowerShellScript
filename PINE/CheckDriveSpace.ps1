###########################################################################################################################
##  Script Purpose : This script will check D drive memory and if its low it will send mail to DevOps team
##  Author Name : Anup Kumar Mishra (anup.mishra@pinelabs.com
## Note : do not delete this Script. First connect the Author
###########################################################################################################################


# Variable Decaration 
$Ipaddress = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

$body = Get-Content D:\checkDriveSpace\mailBody.txt | Out-String
$logFolder= "D:\checkDriveSpace"
###########################################################################################################################

# Logical box 


# $disk = Get-WmiObject Win32_LogicalDisk -ComputerName remotecomputer -Filter "DeviceID='D:'" | Select-Object Size,FreeSpace

$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'" | Select-Object Size,FreeSpace
$disk.Size
$free_size = $disk.FreeSpace / 1GB
Get-Date >> $logFolder\ServerSpacelog.txt
"D Drive Space " >> $logFolder\ServerSpacelog.txt
$free_size >> $logFolder\ServerSpacelog.txt

if($free_size -lt 10)
    {
        #write-host "Memory Size is very low" -ForegroundColor Red
        Send-MailMessage -From 'Nova.application@pinelabs.com' -To 'anup.mishra@pinelabs.com' -Subject 'TRM App Server D drive is full' -Body $body -SmtpServer "192.168.100.11" 
    }
else
    {
        #Write-Host "Memory is fine" -ForegroundColor DarkGreen
    }

"*************************************************************************" >> $logFolder\ServerSpacelog.txt

#Get-PSDrive C | Select-Object Used,Free

###########################################################################################################################