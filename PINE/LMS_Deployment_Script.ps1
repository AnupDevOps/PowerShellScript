#######################################################################################################
###############                   Deployment Script for LMS application                  ##############
#######################################################################################################

$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot 
Write-Host "Enter the UAT server Name"
$UAT_Server_name=Read-Host

Write-Host "Enter the Production server Name"
$UAT_Server_name=Read-Host


# User varaibles
$path="D:\All Basic installation Softwares"
$JarPath="D:\Java_sample_project\JavaProject\java-project\target"
$DeploymentFolderPath="D:\Java_sample_project\apache-tomcat-8.5.40\apache-tomcat-8.5.40\webapps\Sample_PS"

# 1. Login to Application server(UAT)
#TODO
Enter-PSSession -ComputerName "$UAT_Server_name"


# 2. Take the Backup of the .war file from UAT server and placed it under the backup folder.
cd $path

$checkfolderStatus=test-path("$path\$((Get-Date).ToShortDateString())")

if($checkfolderStatus -eq 'True')
    {
        write-host "BackUp Folder is already there" -ForegroundColor Red
    }
else
    {
        New-Item -ItemType Directory -Path ".\$((Get-Date).ToShortDateString())"
        Copy-Item "$JarPath\Sample.jar" "$path\$((Get-Date).ToShortDateString())"
    }

#3. Login to production server and Stop the Tomcat Service.
#TODO
Write-Host "***************************** Stopping the Tomcat Server *****************************" -ForegroundColor DarkRed
#Stop-Service tomcat

# 4. Delete everything from WebApps and Copy paste the .war file which we take it from UAT.
Remove-Item $DeploymentFolderPath\* -Recurse
Copy-Item "$path\$((Get-Date).ToShortDateString())\*.jar" "$DeploymentFolderPath\" -Recurse
Write-Host "***************************** Deployment Done *****************************" -ForegroundColor DarkGreen

#5. Start the Tomcat Service again and check logs if tomcat start properly or not.
#Start-Service tomcat
Write-Host "***************************** Starting the Tomcat Server *****************************" -ForegroundColor DarkGreen

# sleep -Seconds 180


