# get Log date from the user 
#Write-Host "Enter the log day(Like Today/yesterday)"
#$day = "$env:Day"
$day=$args[0]
$time=$args[1]
$usermailID=$args[2]


if($day -ieq "Today")
{
Write-Host "You selected today"
$DeploymentDate =(Get-Date).ToString('yyyy-MM-dd')
$DeploymentDate
}
if ($day -ieq "Yesterday")
{
Write-Host "You selected Yesterday"
$DeploymentDate =(Get-Date).AddDays(-1).ToString('yyyy-MM-dd')
$DeploymentDate
}
else
{
Write-Host "Please contact DevOps team for Logs"
}

#get log time from user
#Write-Host "Enter the Log starting Time in 24 hours format (Like 11/16)"
#$time = "$env:Time"
if ($time.Length -eq 1)
{
$time = "0"+$time
$time
}
else
{
$time
}

# Get Log File name from the user input 
$logfilename = "server.log."+$DeploymentDate+"."+$time
$logfilename 

$logFolderName= "D:\apache-tomcat-8.5.11\logs"
$LogtempFoldername = "E:\LogtempFoldername\"

# Copy the log file from the log folder to temp folder.  

if(Test-Path -Path $logFolderName\$logfilename)
{
Write-Host "File is there."
Copy-Item $logFolderName\$logfilename $LogtempFoldername -Recurse
}
else
{
Write-Host "File is not there sending latest server log"
Copy-Item $logFolderName\server.log $LogtempFoldername -Recurse
}


#Copy-Item $logFolderName\$logfilename $LogtempFoldername -Recurse

$LogFolderSize = (gci $LogtempFoldername | measure Length -s).sum / 1Mb
$LogFolderSize

Compress-Archive -Path $LogtempFoldername\* -Update -DestinationPath $LogtempFoldername\Log.Zip

#write-host "Enter Your mail ID"
#$usermailID = "$env:EmailID"
Write-Host "The email Id to send mails" 
$usermailID

$LogFileSize = (gci $LogtempFoldername\Log.Zip | measure Length -s).sum / 1Mb
$LogFileSize

if ($LogFileSize -lt 2)
{

Send-MailMessage -From 'novadevops@pinelabs.com' -To $usermailID -Subject 'Logs' -Body "Hi Please find attach logs file as per your request" -Attachments $LogtempFoldername\Log.Zip -Priority High -SmtpServer '10.168.207.95'

Remove-Item $LogtempFoldername\* -Recurse

}
else
{
Write-Host "Zipped Log file Size is greater than 1 MB. Please contact Devops team for Logs" 
Send-MailMessage -From 'novadevops@pinelabs.com' -To $usermailID -Subject 'Logs' -Body "Zipped Log file Size is greater than 1 MB. Please contact Devops team for Logs" -Priority High -SmtpServer '10.168.207.95'
}