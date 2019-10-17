Run a PowerShell Script with Argument in Jobs 

$day="$env:Day"
$time="$env:Time"
$email="$env:EmailID"
$day
$time
$email


Invoke-Command -ComputerName NM2LMAP312 -FilePath D:\jenkins\Jenkins_Scripts\LogAutomation.ps1 -ArgumentList $day,$time,$email
