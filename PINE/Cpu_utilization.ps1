write-host "Enter the machine name "
$cname= $env:COMPUTERNAME
write-host "Computer Name" $cname "currently running"
#cpu utilization
Get-WmiObject win32_processor | select LoadPercentage  |fl
Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average

