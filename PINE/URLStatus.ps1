# First we create the request.
#$HTTP_Request = [System.Net.WebRequest]::Create('https://master.pinelabs.com/login')

$HTTP_Request = [System.Net.WebRequest]::Create('https://master.pinelabs.com/login')

# We then get a response from the site.
$HTTP_Response = $HTTP_Request.GetResponse()

# We then get the HTTP code as an integer.
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200) {
    Write-Host "Site is OK!"
    Get-Date >> D:\Work\PowerShell_Scripts\master.txt
    "Master Site is okay" >> D:\Work\PowerShell_Scripts\master.txt
}
Else {
    Write-Host "The Site may be down, please check!"
    Send-MailMessage -From 'Nova.application@pinelabs.com' -To 'anup.mishra@pinelabs.com' -Subject 'Master Application Stopped Working' -Body "Master App is Down" -SmtpServer "192.168.100.11" 

}

# Finally, we clean up the http request by closing it.
$HTTP_Response.Close()