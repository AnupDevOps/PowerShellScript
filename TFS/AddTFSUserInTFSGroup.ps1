cls

$adgroup="Powershell_testing "
$domain="ECBT1\"

write-host "Enter the TFS Group name you want to add"
$adgroup=read-host 

#Command to create new TFS group
tfssecurity /gc "vstfs:///Classification/TeamProject/10a81d4d-fbd8-4f2d-ae61-f61df9fe2cb9" $adgroup  "Testing_powershell_Script" /collection:"TFS-Collection-URL"

write-host "Enter the user name you want to add"
$user=read-host

#command to add user in TFS group
tfssecurity /g+ "IMAS 2.7 Developers" n:$domain$user /collection:"TFS-Collection-URL"

#command to see TFS group detail.
tfssecurity /imx "IMAS 2.6 Developers" /collection:"TFS-Collection-URL"

  
