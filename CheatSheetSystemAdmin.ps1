########################################################################################################################
#####################           PowerShell CheatSheet for System Admin roles             ###############################
########################################################################################################################

# TO get all Services which are stopped 
Get-Service | Where-Object status -EQ 'Stopped'
Get-Service | Where-Object Status -EQ 'Stopped' | Select-Object status, Name, DisplayName | Export-Csv D:\Work\PowerShell_Scripts\Services.csv

# PowerShell commands are mixure of verb-Noun Like "Do something-To something" 

# To get all services on remote computers 
Get-Service -Name m* -ComputerName remotecpname1, remotecpname2 
gsv

# Get help for any commands
Get-Help Get-Service | more 
Update-Help 
# it will update all new updates 

Get-History
# get-history will show you all old commands which you run on your system 
# it will keep the history as long as you open the windows. 
# you can invoke command by using the ID as well
Invoke-History -Id 4

################################   Formatting in PowerShell ################################ 
# Format-list 
# Format-table 
# Format-view 


# Module 3 --- Gathering information with PowerShell 
# Troubleshotting in PowerShell -- Identify the issue -- Find the root cause -- Determine and implement a solution -- Verify results 

# steps --- get-command -- help -- get-memeber 


# Windows management Instrumentation (wmi) --- get-wmiobject 
# Common Information Model (cmi) --- get-ciminstance 

# wmi repository --- cimv2 --- win32-processor --- Device ID, Name 

# Gathering operations systems and hardware information with powerShell 

# Gets performance counter data from local and remote computers.

Get-Counter
Get-Help Get-Counter | more

Get-Counter -ListSet *memory* | where CounterSetName -EQ 'Memory' 

Get-CimInstance Win32_PhysicalMemory
Get-Help Get-CimInstance | more 
# Gets the CIM instances of a class from a CIM server.
Get-CimClass -ClassName *disk*

# to check when the last system restarted 
Get-EventLog System | Where-Object {$_.EventID -eq 41} | select -First 10 

Get-EventLog System | Where-Object {$_.Log -ccontains "setting"} | select -First 10
Get-EventLog -LogName System -InstanceId 60063

# gathering Networking Information 
ipconfig
Get-NetIPAddress 
Get-SmbMapping
New-SmbMapping

# Gathering Registry information with PowerShell 
Get-PSProvider
# Get-Item 

# working with files and printers 
Get-ChildItem
Copy-Item
Move-Item 
Rename-Item 
Get-Printer
Add-Printer
Remove-Printer

# what is active Directory 
Get-ADuser 
search-ADaccount
get-adcomputer 
get-adgroup
get-adGroupMember 
Add-AdGroupMemeber

########### Module 3 Remoting with PowerShell  ###########

winrm

# enable Remote Management with PowerShell 
Enable Remoting
set permissions
modify windows Firewall 

# requirement for remoting with PowerShell 
Enable-PSRemoting
Get-PSSessionConfiguration
Set-PSSessionConfiguration
Set-NetFirewallRule

# to get remoting of a machine 
Enable-PSRemoting
Enter-PSSession -ComputerName remotepc1




##### Scripts to check Free Space in D drive

$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'" | Select-Object Size,FreeSpace
$disk.Size
$free_size = $disk.FreeSpace / 1GB
$free_size

##### Scripts to CPU utilization 

$AVGProc = Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average 
$AVGProc

##### Scripts to Memory utilization 

$OS = gwmi -Class win32_operatingsystem |Select-Object @{Name = "MemoryUsage"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}

