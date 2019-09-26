Stop-Service Tomcat8_UAE_lms

# Delete the D:\apache-tomcat-8.5.11\webapps folder

Remove-Item -Path D:\apache-tomcat-8.5.11\webapps\* -Recurse -Force

# Copy the latest war file from the dropzone and place it under the webapps folders

Copy-Item \\share1\Pine_Noida\Anup.mishra\ROOT.war D:\apache-tomcat-8.5.11\webapps\ -Recurse -Force

Start-Service Tomcat8_UAE_lms

# Script to hit the URl and check if Its working fine or not.

#$IE=new-object -com internetexplorer.application
#$IE.navigate2("www.microsoft.com")
#$IE.visible=$true