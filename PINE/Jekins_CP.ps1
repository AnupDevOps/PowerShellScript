Restart-Service Jenkins -Force
Stop-Service Jenkins -Force
Start-Service Jenkins
 
# TO DO
# Copy to Backup location 
# Delete the file
# Copy the new File there

Copy-Item "Source_Path" -Destination "backup_location"

#Copy-Item "D:\PowerShell_Scripts\*.ps1" -Destination "D:\Pine_labs\"

Remove-Item "Source_Path"

Copy-Item "Source_Path" -Destination "destination"
