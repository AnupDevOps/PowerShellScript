Param (
[Parameter(Mandatory=$true)][string]$ComputerName,
[Parameter(Mandatory=$true)][string]$Username
)

#IP Address
Resolve-DnsName $ComputerName | select Name,IPaddress

#DNS Server
(Get-DnsClientServerAddress `
-CimSession (New-CimSession -ComputerName $ComputerName) `
-InterfaceAlias "ethernet0" -AddressFamily IPv4).ServerAddresses

#OS Description
(Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName).Caption

#SystemMemory
((((Get-CimInstance Win32_PhysicalMemory -ComputerName $ComputerName).Capacity|measure -Sum).Sum)/1gb)

#Last Reboot
(Get-CimInstance -Class Win32_OperatingSystem -ComputerName $ComputerName).LastBootUpTime

#DiskSpace/FreeSpace
#(Invoke-Command -ComputerName $ComputerName {Get-PSDrive| where Name -EQ "C"}).free
$drive=Invoke-Command -ComputerName $ComputerName {Get-PSDrive| where Name -EQ "C"}
$FreeSpace = [Math]::Round(($drive.free)/1gb,2)

#UserInfo
(Get-ADUser -Identity xa_singhsa -Property *).LastLogonDate

#Retrieve group Membership of AD user Account
(Get-ADUser -Identity Xa_singhsa -Property *).memberof

#User Accounts on system
(Get-CimInstance Win32_UserAccount -CimSession $ComputerName).Caption
