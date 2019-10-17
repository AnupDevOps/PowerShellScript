
$date =(Get-Date).ToString('dd-MM-yyyy')
$filename = "E:/threaddump_$date.txt"

$procid=get-process Tomcat8 |select -expand id

cd "C:\Program Files\Java\jdk1.7.0_45\bin"
jstack.exe $procid > $filename

