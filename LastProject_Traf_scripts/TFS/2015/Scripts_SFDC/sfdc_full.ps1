#####################################################################################
#																				   	#
# Description: PowerShell Script to create incremental or full build in SalesForce 	#
#																				   	#
# Author:      Tushar Meshram														#
#																					#				
#####################################################################################

$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot

$srcFolder="${scriptPath}\..\src"
$packageXMLFile="${srcFolder}\package.xml"


$build_name=$env:BUILD_DEFINITIONNAME
$bnumber="${Env:BUILD_BUILDNUMBER}" 
$BldDrop="\\ttrafloco2k910\BINARIES\CRM\SFDC\master\$build_name\$bnumber"
$tempDestLocation="$BldDrop"


$sfun="$Env:sfUsername"
$sfpass="$Env:sfPassword"
$sfserurl="$Env:sfserverurl"


(Get-Content $scriptPath\build.properties) | Foreach { $_ -Replace "user\.", $sfun } | Set-Content $scriptPath\build.properties;
(Get-Content $scriptPath\build.properties) | Foreach { $_ -Replace "password\.", $sfpass } | Set-Content $scriptPath\build.properties;
(Get-Content $scriptPath\build.properties) | Foreach { $_ -Replace "url\.", $sfserurl } | Set-Content $scriptPath\build.properties;


echo "Folder location of src : ${srcFolder}"
echo "Temp Destination location : ${tempDestLocation}"
if(!(Test-Path -Path $tempDestLocation ))
	{
		echo "Directory $tempDestLocation does Not Exists"
		New-Item -ItemType directory -Force -Path "$tempDestLocation"
        echo "Created Directory $tempDestLocation"
	}
else 
	{	
		Remove-Item -Recurse -Force "$tempDestLocation/*"
	}

	
		echo "Required Build files are copied successfully from src location to $tempDestLocation"
		###Copying build.xml located in Scripts folder to ${tempDestLocation}\..
		Copy-Item -Path "${srcFolder}\*" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${scriptPath}\build.xml" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${packageXMLFile}" "${tempDestLocation}" -recurse -Force
		Copy-Item -Path "${scriptPath}\sfdc_deploy.ps1" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${scriptPath}\build.properties" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${scriptPath}\sfdc_deployCodeCheck.ps1" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${scriptPath}\get_buildProperties.ps1" "${BldDrop}" -recurse -Force
		
