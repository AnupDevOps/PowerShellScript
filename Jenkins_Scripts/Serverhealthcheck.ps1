#################################################################################  
##  
## Server Health Check  
## Created by vikash   
## Date : 3 June 2019  
##   
## Email: cmd    
## This scripts check the server Avrg CPU and Memory utlization along with C drive  
## disk utilization and sends an email to the receipents included in the script 
################################################################################  
 
$ServerListFile = "E:\ServerHealth\ServerList.txt"   
#$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue  
$ServerList = Get-Content $ServerListFile 

$Todaydate = (get-date).ToString("yyyy-MM-dd")
$Result = @()  
ForEach($computername in $ServerList)  
{ 
 
$AVGProc = Get-WmiObject -computername $computername win32_processor |  
Measure-Object -property LoadPercentage -Average | Select Average 
$OS = gwmi -Class win32_operatingsystem -computername $computername | 
Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }} 
$vol = Get-WmiObject -Class win32_Volume -ComputerName $computername -Filter "DriveLetter = 'D:'" | 
Select-object @{Name = "D PercentFree"; Expression = {“{0:N2}” -f  (($_.FreeSpace / $_.Capacity)*100) } } 
   
$result += [PSCustomObject] @{  
        ServerName = "$computername" 
        CPULoad = "$($AVGProc.Average)" 
        MemLoad = "$($OS.MemoryUsage)" 
        DDrive = "$($vol.'D PercentFree')" 
    } 
 
 
    $Outputreport = "<HTML><TITLE> Server Health Report </TITLE> 
                     <BODY background-color:green> 
                     <font color =""#99000"" face=""Microsoft Tai le""> 
                     <H2> Server Health Report </H2></font> 
                     <Table border=1 cellpadding=0 cellspacing=0> 
                     <TR bgcolor=gray align=center> 
                       <TD><B>Server Name</B></TD> 
                       <TD><B>Avrg.CPU Utilization</B></TD> 
                       <TD><B>Memory Utilization</B></TD> 
                       <TD><B>D Drive Free Space</B></TD></TR>" 
                         
    Foreach($Entry in $result)  
     
        {  
          #if(($Entry.CpuLoad -or $Entry.memload) -ge '80%')  
          if($Entry.CpuLoad -ge '75' -or $Entry.memload -ge 75 -or $Entry.DDrive -lt 25) 
          {  
           

            $Outputreport += "<TR bgcolor=red>" 
			$counter = 1
			
          }  
          else 
           { 
            $Outputreport += "<TR bgcolor=green>"  
			$counter = 0
             

          } 
          $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.CPULoad)</TD><TD align=center>$($Entry.MemLoad)</TD><TD align=center>$($Entry.Ddrive)</TD></TR>"  
        } 
     $Outputreport += "</Table></BODY></HTML>"  
        }  
		
		if($counter -eq 1)
		{
						$Outputreport | out-file E:\ServerHealth\Test.htm  
						$smtpServer = "10.168.207.95" 
						$smtpFrom = "vikash.jha@pinelabs.com" 
						$smtpTo = "novadevops@pinelabs.com" 
						$messageSubject = "Servers Health report LMS" 
						$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto 
						$message.Subject = $messageSubject 
						$message.IsBodyHTML = $true 
						#$message.Body = "<head><pre>$style</pre></head>" 
						$message.Body += Get-Content E:\ServerHealth\Test.htm 
						$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
						$smtp.Send($message)
                        $cpu = $Entry.CPULoad
                        $memory = $Entry.memload
                        $drive = $Entry.DDrive
                        #$date = Get-Date
                        $date = (Get-Date).ToString('HHmm') 
                        "$cpu, $memory, $drive, $date" >> E:\ServerHealth\CPU_Load_$Todaydate.txt  
		}
		else{
            $cpu = $Entry.CPULoad
            $memory = $Entry.memload
            $drive = $Entry.DDrive
            #$date = Get-Date
            $date = (Get-Date).ToString('HHmm')
            "$cpu, $memory, $drive, $date" >> E:\ServerHealth\CPU_Load_$Todaydate.txt           
		}