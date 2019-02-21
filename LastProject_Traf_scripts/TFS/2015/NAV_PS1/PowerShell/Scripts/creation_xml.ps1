#####################################################################
#
# Description: Creation of xml at run time based on the Traget Machine
#
#
######################################################################


function Valfromconfig()
{   
[CmdletBinding()]
    param 
    (
        [String]$variable        
    )            
$string = $(Get-Content "$scriptPath\..\Config\Configuration.txt" | Select-String $variable).ToString().split("=")[1]
return $string
}


$build_name="${Env:BUILD_DEFINITIONNAME}"

Function callfunction ()
	{
			$xmlWriter.WriteElementString('NavisionInstance',"$serverinstance_name")
			$xmlWriter.WriteElementString('DatabaseName',"$object_folder_file")
			$xmlWriter.WriteElementString('RBAFilePath',"C:\$build_name\")
			$xmlWriter.WriteStartElement('Companies')
			$xmlWriter.WriteStartElement('Company')
			$xmlWriter.WriteElementString('BusinessCompany',"AAF")
			$xmlWriter.WriteElementString('PricingCompany',"AAF_PRC")
			$xmlWriter.WriteEndElement()
			$xmlWriter.WriteStartElement('Company')
			$xmlWriter.WriteElementString('BusinessCompany',"AUA")
			$xmlWriter.WriteElementString('PricingCompany',"AUA_PRC")
			$xmlWriter.WriteEndElement()
			$xmlWriter.WriteStartElement('Company')
			$xmlWriter.WriteElementString('BusinessCompany',"AAP")
			$xmlWriter.WriteElementString('PricingCompany',"AAP_PRC")
			$xmlWriter.WriteEndElement()
			$xmlWriter.WriteStartElement('Company')
			$xmlWriter.WriteElementString('BusinessCompany',"PA2")
			$xmlWriter.WriteElementString('PricingCompany',"PA2_PRC")
			$xmlWriter.WriteEndElement()
			$xmlWriter.WriteStartElement('Company')
			$xmlWriter.WriteElementString('BusinessCompany',"ZZZ ES EPUMA")
			$xmlWriter.WriteElementString('PricingCompany',"")
			$xmlWriter.WriteEndElement()
			$xmlWriter.WriteEndElement()

			$xmlWriter.WriteEndElement()
			$xmlWriter.Flush()
			$xmlWriter.Close()
	}
	
if($build_name -match "nightly")
{

	$folder_name=Get-ChildItem -dir -Name | Select-Object -First 1
	$object_folder_file=Valfromconfig 'Dev_Database'
	$Dev_dbserver=Valfromconfig 'Dev_DBServer'
	$db_name_config=$Dev_dbserver.split("\")
	$Server_name_path=$db_name_config[0]
	$serverinstance_name=$db_name_config[1]
	new-item \\$Server_name_path\$serverinstance_name -type directory -Force
	copy-item "$scriptPath\..\..\Master_Config_Package\*" "\\$Server_name_path\$serverinstance_name" -force 
	remove-item "\\$Server_name_path\$serverinstance_name\Master_Config_Package\Environment\*" -force
	copy-item "$scriptPath\..\..\Master_Config_Package\Environment\$folder_name" "\\$Server_name_path\$serverinstance_name\Environment" -force 
	Rename-Item -path "\\$Server_name_path\$serverinstance_name\Environment\$folder_name" -newName "$serverinstance_name"
	
	$xmlWriter = New-Object System.XMl.XmlTextWriter("\\$Server_name_path\$serverinstance_name\TFS Config.xml",$Null)
	$xmlWriter.WriteStartDocument()
	$xmlWriter.WriteStartElement('Config')
	$xmlWriter.WriteElementString('ServerInstance',"$Dev_dbserver")
	$db_name_config=$Dev_dbserver.split("/")
	$Server_name_path=$db_name_config[0]
	callfunction

}
	

	
elseif($build_name -match "full")
{

		foreach ($object_folder_file in get-content "\\ttrafloco2k910\BINARIES\ePuma\GIT\env_to_refresh.txt")
		{

			$xmlWriter = New-Object System.XMl.XmlTextWriter("C:\$build_name\TFS Config.xml",$Null)
			$xmlWriter.WriteStartDocument()
			$xmlWriter.WriteStartElement('Config')

		if($object_folder_file -Match "TEST" )
			{
				$xmlWriter.WriteElementString('ServerInstance',"DPUMALOCO2K19\NAV_UAT_01")
				$Server_name_path="DPUMALOCO2K19"
				$serverinstance_name=$object_folder_file
			}
		elseif($object_folder_file -Match "DEV" )
			{
				$xmlWriter.WriteElementString('ServerInstance',"DPUMALOCO2K17\NAV_DEV_01")
				$Server_name_path="DPUMALOCO2K18"
				$serverinstance_name=$object_folder_file
			}

			callfunction

		}

}

else 
{
write-host "Unable to configure the build name"  -ForegroundColor yellow
}
