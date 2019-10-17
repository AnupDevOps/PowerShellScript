# Scripts Variables 
# Change Below Varaibles as per variables
$ServiceName = "Tomcat8_LMS"
$TomcatFolderPath = "D:\apache-tomcat-8.5.11"
$WarBackUpFolderPath = "E:\Backup"
$DeploymentDate =(Get-Date).ToString('dd-MM-yyyy')



Write-host "Deployment starting" 
get-date
# Stop the Service of Tomcat

Stop-Service $ServiceName -Force

Start-Sleep -s 3

#exit 0

# Wait for Db team to take backup of Db and run scripts which is provided by Developers.

# DBA TODO

# After Confirmation 


# Delete the D:\apache-tomcat-8.5.11\webapps folder

Remove-Item -Path $TomcatFolderPath\webapps\* -Recurse -Force

# In Case they Suggest to emplty work and Temp folder


Remove-Item $TomcatFolderPath\temp\* -Recurse -Force

Remove-Item $TomcatFolderPath\work\* -Recurse -Force

# Copy the latest war file from the dropzone and place it under the webapps folders

Copy-Item $WarBackUpFolderPath\$DeploymentDate\ROOT.war $TomcatFolderPath\webapps\ -Recurse -Force


# Start the service and wait for the URL to come online. 

Start-Service $ServiceName

Write-host "Deployment Complete" 
get-date

