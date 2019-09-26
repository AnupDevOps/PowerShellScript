#################################################################################  
##  
## Tomcat Server Log check for ERROR and Exception 
## Created by Anup Kumar Mishra   
## Date : 28 June 2019  
##   
## Email: cmd    
## This scripts check the tomcat server logs and filter out Error and Exception and produce a file for ERROR and Exception. 
################################################################################  


$LogFolderPath="C:\Users\anup.mishra\Desktop\LMS_Logs\server.log.2019-06-26"


$Todaydate = (get-date).AddDays(-1).ToString("yyyy-MM-dd")


for($i=1; $i -lt 24; $i++)
{ 
$filename = "server.log."+$Todaydate+"."+$i
if(Test-Path -path $FolderPath\$filename)
{
Get-Content $FolderPath\$filename | Select-String "ERROR" -CaseSensitive >> C:\Users\anup.mishra\Desktop\LMS_Logs\Error_Log.txt
Get-Content $FolderPath\$filename | Select-String "Exception" -CaseSensitive >> C:\Users\anup.mishra\Desktop\LMS_Logs\Exception_Log.txt
}
else
{
Write-Warning "$FolderPath\$filename file doesnot exist" 
}

}