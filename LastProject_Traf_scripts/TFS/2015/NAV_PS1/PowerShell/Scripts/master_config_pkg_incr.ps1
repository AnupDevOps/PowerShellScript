echo "Get the CheckOut Version ${Env:TF_BUILD_SOURCEGETVERSION}"

$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot

function Valfromconfig()
{   
[CmdletBinding()]
    param 
    (
        [String]$variable        
    )            
$string = $(Get-Content "$scriptPath\..\Config\BuildConfiguration.txt" | Select-String $variable).ToString().split("=")[1]
return $string
}


$BldChngSetFolder="C:\ePuma_Prod\Build-Changeset"
$BldChngSetFlFolder="$scriptPath\..\Master-ChangesetFiles"

$AutomationCodeLocation="$scriptPath\..\..\Master_Config_Package"
$extSuccessVerFile="$BldChngSetFolder\Master_Config_Dev.txt"
$LogFolder="$scriptPath\..\Build-Logs"
$versionlist="${Env:BUILD_BUILDNUMBER}"
$extAutoPath=Valfromconfig 'extMastersrcPath'
$wspath="${Env:BUILD_REPOSITORY_LOCALPATH}"	
$artifactdir="$scriptPath\..\..\artifact"


Set-Location -Path "${AutomationCodeLocation}"
#Remove-Item $artifactdir/* -Recurse -Force


if (!(Test-Path -Path $BldChngSetFolder ))
	{
		echo "Directory $BldChngSetFolder does Not Exists"
		New-Item -ItemType directory -Path $BldChngSetFolder
		echo "Created Directory $BldChngSetFolder"
	}

if(!(Test-Path -Path $LogFolder ))
	{
		echo "Directory $LogFolder does Not Exists"
		New-Item -ItemType directory -Path $LogFolder
		echo "Created Directory $LogFolder"
	}
else 
	{
		Remove-Item "$LogFolder\*.txt" -Force
	}

if (!(Test-Path -Path $BldChngSetFlFolder ))
	{
		echo "Directory $BldChngSetFolder does Not Exists"
		New-Item -ItemType directory -Path $BldChngSetFlFolder
		echo "Created Directory $BldChngSetFlFolder"
	}
else
	{
		Remove-Item "$BldChngSetFlFolder\*.txt" -Force
	}

		git diff --name-status HEAD~..HEAD > $LogFolder/MasterChangeSet.txt 

#### Check for Global or Setup folders ######

		Get-Content "$LogFolder\MasterChangeSet.txt" | ForEach-Object {
			if ( $_ -match "Master_Config_Package/Global" -or "Master_Config_Package/Setup" )
				{ $_ >> $LogFolder/global.txt }
			if ( $_ -match "Master_Config_Package/Environment" )
				{ $_ >> $LogFolder/envfolder.txt }
			}

#### Global and Setup folder 
	if ( Test-Path -Path $LogFolder\global.txt )
		{
		Get-Content "$LogFolder\global.txt" | ? {$_.trim() -ne "" }|Out-File  "$LogFolder\global2.txt"				
		Get-Content "$LogFolder\global2.txt" | foreach {($_ -split '\s+',2)[1..1]}|Out-File  "$LogFolder\global3.txt"
		Get-Content "$LogFolder\global3.txt" | Foreach-Object {$_.split('/')[2]} |Out-File  "$LogFolder\globalfinalchangeset.txt"
		Get-Content ("$LogFolder/globalfinalchangeset.txt" ) > $LogFolder/extfinalchangeset.txt
		cd $wspath\artifact
		Get-Content "$LogFolder\global3.txt" | 
		ForEach-Object {
			$dirPath = split-Path $_
			New-Item $dirPath -ItemType Directory -force
			Copy-Item "$wspath\$_" "$dirPath" -force
			}
		}

#### Environment Folder
	if ( Test-Path -Path $LogFolder\envfolder.txt )
		{
		Get-Content "$LogFolder\envfolder.txt" | ? {$_.trim() -ne "" }|Out-File  "$LogFolder\envfolder2.txt"				
		Get-Content "$LogFolder\envfolder2.txt" | foreach {($_ -split '\s+',2)[1..1]}|Out-File  "$LogFolder\envfolder3.txt"
		Get-Content "$LogFolder\envfolder3.txt" | Foreach-Object {$_.split('/')[2]} |Out-File  "$LogFolder\envfinalchangeset.txt"
		Get-Content ("$LogFolder/envfinalchangeset.txt" ) >> $LogFolder/extfinalchangeset.txt
		cd $wspath\artifact
		Get-Content "$LogFolder\envfolder3.txt" | 
		ForEach-Object {
			$dirPath = split-Path $_
			New-Item $dirPath -ItemType Directory -force
			Copy-Item "$wspath\$_" "$dirPath" -force
			}

		}

	if ( Test-Path -Path $LogFolder\extfinalchangeset.txt )
		{
			$extFinalChangeSet=Get-Content "$LogFolder\extfinalchangeset.txt"
			echo $extFinalChangeSet >> $extSuccessVerFile
			$extfilename="$extSuccessVerFile"
			$extvalidFiles=gc $extfilename | sort | get-unique
			echo $extvalidFiles > $extSuccessVerFile
			Write-Host "Files Sorted"
		}
		
cd $AutomationCodeLocation\Environment
Get-ChildItem -dir -Name > $artifactdir\env_names.txt 