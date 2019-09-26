# Stop the Service of Tomcat

Stop-Service Tomcat8_LMS -Force

#exit 0

# Wait for Db team to take backup of Db and run scripts which is provided by Developers.

# DBA TODO

# After Confirmation 


# Delete the D:\apache-tomcat-8.5.11\webapps folder

Remove-Item -Path D:\apache-tomcat-8.5.11\webapps\* -Recurse -Force

# In Case they Suggest to emplty work and Temp folder


Remove-Item D:\apache-tomcat-8.5.11\temp\* -Recurse -Force

Remove-Item D:\apache-tomcat-8.5.11\work\* -Recurse -Force

# Copy the latest war file from the dropzone and place it under the webapps folders

Copy-Item E:\Backup\19-06-2019\ROOT.war D:\apache-tomcat-8.5.11\webapps\ -Recurse -Force


# Start the service and wait for the URL to come online. 

Start-Service Tomcat8_LMS

