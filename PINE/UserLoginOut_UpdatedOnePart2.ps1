param (
    $queryResults = $null,
    [string]$UserName = $env:USERNAME,
    [string]$ServerName = "INUNWLMSAP331"
)


if (Test-Connection $ServerName -Count 1 -Quiet) {  
    Write-Host "`n`n`n$ServerName is online!" -BackgroundColor Green -ForegroundColor Black


    Write-Host ("`nQuerying Server: `"$ServerName`" for disconnected sessions under UserName: `"" + $UserName.ToUpper() + "`"...") -BackgroundColor Gray -ForegroundColor Black

        query user $UserName /server:$ServerName 2>&1 | foreach {  

            if ($_ -match "Active") {
                Write-Host "Active Sessions"
                $queryResults = ("`n$ServerName," + (($_.trim() -replace ' {2,}', ','))) | ConvertFrom-Csv -Delimiter "," -Header "ServerName","UserName","SessionName","SessionID","CurrentState","IdealTime","LogonTime"


                $queryResults | ft
                Write-Host "Starting logoff procedure..." -BackgroundColor Gray -ForegroundColor Black

                $queryResults | foreach {
                    $Sessionl = $_.SessionID
                    $Serverl = $_.ServerName
                    #Write-Host "Logging off"$_.username"from $serverl..." -ForegroundColor black -BackgroundColor Gray
                    #sleep 2
                    #logoff $Sessionl /server:$Serverl /v

                }


            }                
            elseif ($_ -match "Disc") {
                Write-Host "Disconnected Sessions"
                $queryResults = ("`n$ServerName," + (($_.trim() -replace ' {2,}', ','))) |  ConvertFrom-Csv -Delimiter "," -Header "ServerName","UserName","SessionID","CurrentState","IdealTime","LogonTime"

                $queryResults | ft
                Write-Host "Starting logoff procedure..." -BackgroundColor Gray -ForegroundColor Black

                $queryResults | foreach {
                    $Sessionl = $_.SessionID
                    $Serverl = $_.ServerName
                    Write-Host "Logging off"$_.username"from $serverl..."
                    sleep 2
                    logoff $Sessionl /server:$Serverl /v

                }
            }
            elseif ($_ -match "The RPC server is unavailable") {

                Write-Host "Unable to query the $ServerName, check for firewall settings on $ServerName!" -ForegroundColor White -BackgroundColor Red
            }
            elseif ($_ -match "No User exists for") {Write-Host "No user session exists"}

    }
}
else {

    Write-Host "`n`n`n$ServerName is Offline!" -BackgroundColor red -ForegroundColor white
    Write-Host "Error: Unable to connect to $ServerName!" -BackgroundColor red -ForegroundColor white
    Write-Host "Either the $ServerName is down or check for firewall settings on server $ServerName!" -BackgroundColor Yellow -ForegroundColor black
}





Read-Host "`n`nScript execution finished, press enter to exit!"