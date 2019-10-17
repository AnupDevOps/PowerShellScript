# Scripts Variables 
# Change Below Varaibles as per variables
$ServiceName = "Tomcat8_LMS"

Write-host "Stopping the server" 
get-date
# Stop the Service of Tomcat

Stop-Service $ServiceName -Force

# wait for some time. 

Start-Sleep -s 5

# Start the service and wait for the URL to come online. 

Start-Service $ServiceName

Write-host "Server start again" 
get-date

