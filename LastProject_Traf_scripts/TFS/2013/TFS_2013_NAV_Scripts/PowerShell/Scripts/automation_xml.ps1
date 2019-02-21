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

$TfPath=Valfromconfig 'TFS Folder Path'
$NAVFolder=Valfromconfig 'RTC Client Path'
$env:PATH += ";${TfPath};${NAVFolder}"
$BldChngSetFolder="C:\ePuma_Prod\Build-Changeset"
$BldChngSetFlFolder="$scriptPath\..\extBuild-ChangesetFiles"
$BldDrop="${Env:TF_BUILD_DROPLOCATION}"
$AutomationCodeLocation="$scriptPath\..\..\Automation_input_xml"
$extSuccessVerFile="$BldChngSetFolder\DevExtSuccessVersionIncr.txt"
$versionlist="${Env:TF_BUILD_BUILDNUMBER}"
$BuildChngSetInfoFl="${BldDrop}\${versionlist}_DevExtChangeSet.txt"
$BldDateFolder="${BldDrop}\${versionlist}"
$extAutoPath=Valfromconfig 'extAutosrcPath'
$tfsCollection=Valfromconfig 'tfsCollectionURL'
$LogFolder="$scriptPath\..\Build-Logs"

Set-Location -Path "${AutomationCodeLocation}"
New-Item -ItemType directory -Path $BldDrop\XML_File
New-Item -ItemType directory -Path $BldDrop\Automation_input_xml -force

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
if (!(Test-Path -Path $extSuccessVerFile))
	{
		
		Write-Host "Creating new Success Version external File" -ForegroundColor Yellow
		$extchArr=tf history . /r /noprompt |% {if ($_ -match "^\d+") {echo $matches[0]}}
		$extchArr=[array]$extchArr
		$extchArr=$extchArr | sort {[int]$_}
		$extchArr=[array]$extchArr
		$extversionNum=$extchArr[0]
		echo $extversionNum > $extSuccessVerFile
		$extLatestChSet=$extchArr[$extchArr.Length-1]
		$dayZero="T"
		Write-Host "External Build Version Considered: $extversionNum" -ForegroundColor Yellow
	}
else 
	{
		$dayZero="F"
		$extversionNumCheck=$(cat $extSuccessVerFile).trim()
		$extversionNumCheck = [array]$extversionNumCheck
		if	( $extversionNumCheck.Length -ne 1 )
			{
				Write-Host "The number of entries\lines in external file $extSuccessVerFile is zero or more than one.Please check the file" -ForegroundColor Red
				Write-Host "Exiting from Automation_xml" -ForegroundColor Red
				exit 1
			}	
		else
			{
				if	($extversionNumCheck[0] -match "^\d+$")
					{
						$extversionNum=$extversionNumCheck[0]
					}
				else
					{
						Write-Host "The Changeset : $($extversionNum[0]) in the external file $extSuccessVerFile is not correct" -ForegroundColor Red
						Write-Host "Exiting from Automation_xml" -ForegroundColor Red
						exit 1
					}
			}
		Write-Host "`nLast Success Build Version : $extversionNum" -ForegroundColor Yellow		
	}

if ($dayZero -eq "F")
	{
		[array]$extLatestchArr = tf history . /r /version:C$extversionNum~${Env:TF_BUILD_SOURCEGETVERSION} /noprompt |% {if ($_ -match "^\d+") {echo $matches[0]}}	
		
		if ($extversionNum -eq $extLatestchArr[0])		
			{
				Write-Host "`nNo version update since last successful build version : $extversionNum" -ForegroundColor Yellow
				Write-Host "No Changeset found to Build. So Exiting from Automation_xml!!!"
				Write-Host "Invoking another script"
				Invoke-Expression $scriptPath\Incr_RM_Build.ps1
				#exit 0
			}
			else
			{
				$extchArr = $extLatestchArr | Where-Object { $_ -ne $extversionNum }
				$extchArr=$extchArr | sort {[int]$_}
				$extchArr = [array]$extchArr
				$extLatestChSet=$extchArr[$extchArr.Length-1]		
			}
	}
#. .\Incr_RM_Build.ps1
#$flag=2
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




Write-Host "The extChangesets are $($extchArr -join ',')"

################
# Ext file logic
################

function MakeBuild
{
[CmdletBinding()]
    param 
    (
        [array]$extChangesets
	)
	
		$extvalidFiles=@()
		$extdeletedFiles=@()
		foreach ($extchangeNum in $extChangesets)
				{
					$extbuildFiles=@()
					$extchangeSetFile="${LogFolder}\${extchangeNum}_DevExtChangeSet.txt"
					tf.exe changeset ${extchangeNum} /collection:${tfsCollection} /noprompt > ${extchangeSetFile}
					$extChangeData = $(Get-Content ${extchangeSetFile})
					$(echo "ChangetSet ${extchangeNum}";echo "") >> $BuildChngSetInfoFl
					$extChangeData -match "(\s+[a-z]+.*\s\$\/)" >> $BuildChngSetInfoFl
					echo "" >> $BuildChngSetInfoFl
##					Please make sure $extAutoPath is defined in the script to get the result#########
					$extvalidObjects=$($extChangeData -match "(add\s+\${extAutoPath}\W+)|(merge\s+\${extAutoPath}\W+)|(edit\s+\${extAutoPath}\W+)"|% {$_ -replace "edit|add|merge|\$extAutoPath/",""}|% {$_.trim()})
					
									
					$extdeleteObjects=$($extChangeData -match "(delete\s+\${extAutoPath}\/\W+)"|% {$_ -replace "delete|\$extAutoPath/|;.*",""}|% {$_.trim()})
					$extvalidObjects > ${BldChngSetFlFolder}\${extchangeNum}_valid_ext_changeset.txt
					$extdeleteObjects >  ${BldChngSetFlFolder}\${extchangeNum}_delete_ext_changeset.txt
					$extvalidFiles += $extvalidObjects
					$extdeletedFiles += $extdeleteObjects
				}
		
		$extvalidFiles=$extvalidFiles|select -uniq 
		$extvalidFiles > ${BldChngSetFlFolder}\Uniq_valid_ext_changeset.txt
		$extdeletedFiles=$extdeletedFiles|select -uniq			
		$extdeletedFiles > ${BldChngSetFlFolder}\Uniq_ext_delete_changeset.txt
		####Get the local workspace to latest changeset####
		echo "Getting the local workspace to latest changeset : $extLatestChSet"
		#tf get /version:$extLatestChSet
		
		foreach($extdelFl in $extdeletedFiles)
				{	
					$extobjectType=$extdelFl.split("/")[0]
					$objectName=$extdelFl.split("/")[1]
					if ($extvalidFiles -contains $extdelFl)
						{	
							$objectFileName="$AutomationCodeLocation\"
							if (!(Test-Path $objectFileName)) 
								{
									echo "$objectFileName is not available at $AutomationCodeLocation"
									$extvalidFiles=$extvalidFiles -ne ${extdelFl}
								}
						}				
				}

		$extvalidFiles > ${BldChngSetFlFolder}\Final_object_ext_file.txt

		if ($extvalidFiles.Length -eq 0)
			{
				Write-Host "Build will not be created as there are no valid external files considered to create an incremental build"
				Write-Host "Build Success" -ForegroundColor Green
				echo $extLatestChSet >  $extSuccessVerFile
				Write-Host "Invoking another script"
				Invoke-Expression $scriptPath\Incr_RM_Build.ps1
				#exit 0			
			}
		else
			{
				echo "The Files considered for incremental changes are -> $extvalidFiles"
				#Write-Host "Build will be created for total $($extvalidFiles.Length) files"
			}
	$extfilepath="${BldChngSetFlFolder}\Final_object_ext_file.txt"
	if	( $extfilepath.Length -ne 0 )
		{
			$extfileexactpath=Get-Content $extfilepath
			$extfileexactpath|foreach {${Env:TF_BUILD_SOURCESDIRECTORY}+"\"+"Automation_input_xml"+"\" + $_} > ${BldChngSetFlFolder}\Appended_file_path.txt

	#### Copy the files to Droplocation
			$read_exact_file_Path=Get-Content ${BldChngSetFlFolder}\Appended_file_path.txt
		
			foreach($filepath in $read_exact_file_Path) 
				{
					Copy-Item -path "$filepath" "$BldDrop\XML_File" -recurse -Force
				}
			Copy-Item -path "$BldDrop\XML_File/*"  -Destination "${BldDrop}/Automation_input_xml" -Container -force -recurse
			Write-Host "Build Successful" -ForegroundColor Green
			Write-Host "Latest ChangeSet is $extLatestChSet"
			Write-Host "Success version  ChangeSet is $extSuccessVerFile"
			echo $extLatestChSet >  $extSuccessVerFile
			Invoke-Expression $scriptPath\Incr_RM_Build.ps1
		}
	else
	{
			echo "No Changes in the Automation input xml folder"
			echo "Nothing to Copy"
	}

	
}
MakeBuild -extChangesets $extchArr