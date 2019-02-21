#####################################################################################
#																				   	#
# Description: PowerShell Script to Deploy SalesForce #
#																				   	#
# Author:      Tushar Meshram														#
#																					#				
#####################################################################################

$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot


echo "Executing Ant Build.xml"
hostname
$build_name=$env:BUILD_DEFINITIONNAME
$bnumber="${Env:BUILD_BUILDNUMBER}" 
$srcFolder="c:\BINARIES\CRM\SFDC\master\$build_name\$bnumber"
cd $srcFolder

		Remove-Item "layouts\SocialPost-Social Post Layout.layout" -Force
		Remove-Item "layouts\EntityMilestone-Object Milestone Layout.layout" -Force
		Remove-Item "workflows\EntityMilestone.workflow" -Force
		Remove-Item "workflows\SocialPost.workflow" -Force
		Remove-Item "settings\knowledge.settings" -Force
		Remove-Item "settings\search.settings" -Force
		Remove-Item "samlssoconfigs" -Recurse -Force
		Remove-Item "portals\Customer Portal.portal" -Force
		#Remove-Item "email\unfiled*public" -Recurse -Force
		#Remove-Item "reports\unfiled*public" -Recurse -Force
		#Remove-Item -Path "documents\Communities_Shared_Document_Folder" -Recurse -Force  -ErrorAction Ignore
		Remove-Item "flows" -Recurse -Force
		
$env:ANT_HOME="C:\apache-ant-1.9.8"
$anthome="C:\apache-ant-1.9.8"
#$env:JAVA_HOME="C:\apache-ant-1.9.7-bin"
echo "ANT_HOME is $env:ANT_HOME"
echo "JAVA_HOME is $env:JAVA_HOME"
ant -f build.xml deployCodeCheckOnly


if ($?) 
	{ 
		echo "ANT deployCodeCheckOnly BUILD SUCCESS"
		exit 0
	} 
else 
	{
		echo "ANT deployCodeCheckOnly BUILD FAILED"
		exit 1
	}