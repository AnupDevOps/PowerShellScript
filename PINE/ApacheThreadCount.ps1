
Remove-Item D:\thread.txt
$name = "httpd.exe"

$processHandle = (Get-CimInstance Win32_Process -Filter "Name = '$name'").ProcessId

$processHandle > D:\thread.txt

foreach($count in Get-Content D:\thread.txt)
{

$Threads = Get-CimInstance -ClassName Win32_Thread -Filter "ProcessHandle = $count" 

$Threads | Select-Object priority, thread*, User*Time, kernel*Time |

Out-GridView -Title "The $name process has $($Threads.count) threads for Thread ID $count"
}
