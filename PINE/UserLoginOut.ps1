

Get-WmiObject -class win32_process -Filter "name = 'Explorer.exe'" -ComputerName INUNWLMSAP331 -EA "Stop" | % {$_.GetOwner().User} >> D:\userinfo.txt



$userName = 'vikash.jha'
$sessionId = ((quser /server:INUNWLMSAP331 | Where-Object { $_ -match $userName }) -split ' +')[2]
$sessionId

logoff $sessionId /server:INUNWLMSAP331