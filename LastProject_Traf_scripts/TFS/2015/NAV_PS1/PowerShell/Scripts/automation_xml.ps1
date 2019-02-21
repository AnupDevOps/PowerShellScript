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

$gitPath="C:\Program Files\Git\cmd"
$env:PATH += ";${gitPath};${NAVFolder}"
$BldChngSetFolder="C:\ePuma_Prod\Build-Changeset"
$BldChngSetFlFolder="$scriptPath\..\extBuild-ChangesetFiles"
$AutomationCodeLocation="$scriptPath\..\..\Automation_input_xml"
$extSuccessVerFile="$BldChngSetFolder\DevExtSuccessVersion_Sprint5.txt"
$versionlist="${Env:BUILD_BUILDNUMBER}"
$extAutoPath=Valfromconfig 'extAutosrcPath'
$LogFolder="$scriptPath\..\Build-Logs"
$artifactdir="$scriptPath\..\..\artifact"
#$BldDrop="\\ttraflon2k922\BINARIES\ePuma\GIT"
$deployscript1="${scriptPath}\mcp_deploy.ps1"
$deployscript2="${scriptPath}\rm_deploy.ps1"
#$deployscript3="${scriptPath}\rm_deploy.ps1"


Set-Location -Path "${AutomationCodeLocation}"
Remove-Item $artifactdir/*

Copy-Item -Path "${deployscript1}" "${artifactdir}" -recurse -Force
Copy-Item -Path "${deployscript2}" "${artifactdir}" -recurse -Force
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
if ((Test-Path -Path $extSuccessVerFile))
	{
		$dayZero="F"
		git diff --name-status HEAD~..HEAD > $LogFolder/extChangeSet.txt
		Get-Content "$LogFolder\extChangeSet.txt" | Select-string -pattern 'NAV/Automation_input_xml' -SimpleMatch | Out-File  "$LogFolder\extchangeset1.txt"
		Get-Content "$LogFolder\extchangeset1.txt" | ? {$_.trim() -ne "" }|Out-File  "$LogFolder\extchangeset2.txt"
		Get-Content "$LogFolder\extchangeset2.txt" | foreach {($_ -split '\s+',2)[1..1]}|Out-File  "$LogFolder\extchangeset3.txt"
		Get-Content "$LogFolder\extchangeset3.txt" | Foreach-Object {$_.split('/')[2]} |Out-File  "$LogFolder\extfinalchangeset.txt"
		$extFinalChangeSet=Get-Content "$LogFolder\extfinalchangeset.txt"
		echo $extFinalChangeSet >> $extSuccessVerFile
		$extfilename="$extSuccessVerFile"
		$extvalidFiles=gc $extfilename | sort | get-unique
		echo $extvalidFiles > $extSuccessVerFile
		Write-Host "Files Sorted"
	}



if((gc $extSuccessVerFile) -eq $null)
			{
				
				Write-Host "`nNo version update since last successful build version : $extversionNum" -ForegroundColor Yellow
				Write-Host "No Changeset found to Build. So Exiting from Automation_xml!!!"
				Write-Host "Invoking another script"
				Invoke-Expression $scriptPath\nav_incr_build.ps1

			}
else
			{

				Copy-Item -Path "${deployscript}" "${artifact}" -recurse -Force
					foreach ($extchangeNum in $extvalidFiles)
						{
							Copy-Item -path $extchangeNum $artifactdir -recurse -Force 
							
						}
					clear-content $extSuccessVerFile				
			}
	
#. .\Incr_RM_Build.ps1

if($flag -eq 0)
{
echo "flag value is $flag"
exit 1
}
if($flag_fail -eq 0)
{
echo "flag failed value is $flag_fail"
exit 1
}
if($flag_success -eq 1)
{
echo "Flag Success is $flag_success"
exit 0
}
