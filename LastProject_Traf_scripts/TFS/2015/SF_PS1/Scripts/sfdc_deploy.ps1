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
cd "c:\BINARIES\CRM\SFDC\master\$build_name\$bnumber"
pwd
$env:ANT_HOME="C:\apache-ant-1.9.8"
$anthome="C:\apache-ant-1.9.8"
#$env:JAVA_HOME="C:\apache-ant-1.9.7-bin"
echo "ANT_HOME is $env:ANT_HOME"
echo "JAVA_HOME is $env:JAVA_HOME"
ant -f build.xml deployCode

if ($?) 
	{ 
		echo "ANT deployCode BUILD SUCCESS"
		exit 0
	} 
else 
	{
		echo "ANT deployCode BUILD FAILED"
		exit 1
	}