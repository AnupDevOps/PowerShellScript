## Incremental script for Navision Build

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

Function Get-NAVObjectTypeIdFromName( [String]$TypeName)
{
     switch ($TypeName)
    {
        "TableData" {$Type = 0}
        "Table" {$Type = 1}
        "Page" {$Type = 8}
        "Codeunit" {$Type = 5}
        "Report" {$Type = 3}
        "XMLPort" {$Type = 6}
        "Query" {$Type = 9}
        "MenuSuite" {$Type = 7}
    }
    Return $Type
}

$NAVFolder=Valfromconfig 'RTC Client Path'
$NavisionCodeLocation="$scriptPath\..\..\NavWorkspace"
$BldChngSetFlFolder="$scriptPath\..\Build-ChangesetFiles"
$BldChngSetFolder="C:\ePuma_Prod\Build-Changeset"
$SuccessVerFile="$BldChngSetFolder\SuccessVersion_DevSprint5.txt"
$LogFolder="$scriptPath\..\Build-Logs"
$gitPath="C:\Program Files\Git\cmd"
$env:PATH += ";${gitPath}"
$branchname="${Env:BUILD_SOURCEBRANCHNAME}"
$versionlist="${Env:BUILD_BUILDNUMBER}"
$srcdir="${ENV:BUILD_SOURCESDIRECTORY}"
$artifactdir="$scriptPath\..\..\artifact"
$Server=Valfromconfig 'Dev_DBServer'
$Database=Valfromconfig 'Dev_Database'
#$BldDrop="\\ttraflon2k922\BINARIES\ePuma\GIT"
$fobbuildfile="$artifactdir\$versionlist.fob"
$rmfobfile="$artifactdir\RM.fob"
if(!(Test-Path -Path $LogFolder ))
	{
		echo "Directory $LogFolder does Not Exists"
		New-Item -ItemType directory -Path $LogFolder
		echo "Created Directory $LogFolder"
	}
else 
	{
	#	Remove-Item "$LogFolder\*.txt" -Force
	}
if(!(Test-Path -Path $srcdir\${versionlist}))
	{
		#New-Item -ItemType directory -Path $srcdir\${versionlist}
	}

if (!(Test-Path -Path $BldChngSetFolder ))
	{
		echo "Directory $BldChngSetFolder does Not Exists"
		New-Item -ItemType directory -Path $BldChngSetFolder
		echo "Created Directory $BldChngSetFolder"
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

if ((Test-Path -Path $SuccessVerFile))
	{
		$dayZero="F"
		git diff --name-status HEAD~..HEAD > $LogFolder/ChangeSet.txt
        Get-Content "$LogFolder\ChangeSet.txt" | Select-string -pattern 'NavWorkspace/' -SimpleMatch | Out-File  "$LogFolder\changeset1.txt"
        Get-Content "$LogFolder\changeset1.txt" | ? {$_.trim() -ne "" }|Out-File  "$LogFolder\changeset2.txt"
        Get-Content "$LogFolder\changeset2.txt" | Foreach-Object { $_.split()[4]}|Out-File  "$LogFolder\changeset3.txt"
        Get-Content "$LogFolder\changeset3.txt" | Foreach-Object {$_.split('/')[2]} |Out-File  "$LogFolder\finalchangeset.txt"
		$FinalChangeSet=Get-Content "$LogFolder\finalchangeset.txt"
		echo $FinalChangeSet >> $SuccessVerFile
		$filename="$SuccessVerFile"
		$validFiles=gc $filename | sort | get-unique
		echo $validFiles > $SuccessVerFile
	}

$measure = Get-Content "$LogFolder\finalchangeset.txt" | Measure-Object
$Changesets =  $measure.Count

$chArr=$Changesets

################
# Fob logic here
################
function MakeBuild
{
[CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
		[array]$Changesets
    )

		$validFiles=@()
		$deletedFiles=@()
		#foreach ($changeNum in $Changesets)
		#		{
					$buildFiles=@()
					$changeSetFile= "$SuccessVerFile"
					$ChangeData = $(Get-Content ${changeSetFile})
					$filename="$SuccessVerFile"
					$validFiles=gc $filename | sort | get-unique
					Set-Location -Path "${NavisionCodeLocation}"
					$validFiles > ${BldChngSetFlFolder}\Final_object_file.txt
		#		}
if ($ValidFiles.Length -eq 0)
			{
				Write-Host "Build will not be created as there are no valid files considered to create an incremental build"
				Write-Host "Build Success" -ForegroundColor Green
				#echo $LatestChSet >  $SuccessVerFile
				[int] $global:flag_success = 1 
				exit 1;
				
			}
		else
			{
				echo "The Files considered for incremental Fob are -> $($($validFiles|%{ $_.Split('/')[3];}) -join ', ')"
				#Write-Host "Build will be created for total $($ValidFiles.Length) files"
			}
				
$ImpCompFlag="T"
	
	foreach ($objFl in $validFiles)
			{
				$objectType=$objFl.split("_")[0]
				$objectFileName=$objFl
				$ID=$($objectFileName -match "\d+" > $null;$matches[0])
				$LogFile = "$LogFolder\Error_import_$objectFileName"
				$importFile = "$NavisionCodeLocation\$objectType\$objectFileName"
				$Type=Get-NAVObjectTypeIdFromName($objectType)
				if (Test-Path "$Logfolder\navcommandresult.txt") 
					{
						Remove-Item "$Logfolder\navcommandresult.txt"
					}			
				$finSqlCommand = """$NAVFolder\finsql.exe"" command=importobjects,file=$importFile,servername=$Server,database=$Database,synchronizeschemachanges=force,importaction=overwrite,Logfile=$LogFile, navservername=TTRAFLOCO2K910, navserverinstance=$Database, navservermanagementport=7031, filter=Type=$objecttype;ID=$ID"
				Write-Debug $finSqlCommand
				cmd /c $finsqlCommand
				write-host "Import completed"
				if (Test-Path $LogFile)
					{
						Write-Host "Error in import for $importFile.Please Check $LogFile for more Details"
						Write-Host "----------------------------------------------------------------------" -ForegroundColor Red
						cat $LogFile
						Write-Host "----------------------------------------------------------------------" -ForegroundColor Red
						$ImpCompFlag="F"
						
						}
				else 
					{
						Write-Host "Object with [ID]=$ID and Type=$Type Imported sucessfully" -ForegroundColor Green
					}
			}	
	
		if ($ImpCompFlag -eq "F")
			{				
				Write-Host "There are one or more import errors encountered while importing the objects into Navision" -ForegroundColor Red
				Write-Host "Please check the logs at $LogFolder for more information....." -ForegroundColor Red
				if ($dayZero -eq "T")
					{
						if (Test-Path ${SuccessVerFile}) 
							{	
								Remove-Item "${SuccessVerFile}" -Force
							}	
					}
					
				Write-Host "Build FAILED" -ForegroundColor Red
				[int] $global:flag_fail = 0 
				#echo $FinalChangeSet >> $SuccessVerFile
				exit 1
			}
		else 
			{
				Write-Host "Import of all the objects completed sucessfully" -ForegroundColor Green			
			}
			
		#Performing Compilation of the objects which are imported into Navision			
		#Setting the Flag initially as True
		$ImpCompFlag="T"

		foreach ($objFl in $validFiles)
			{
				$objectType=$objFl.split("_")[0]
				$objectFileName=$objFl
				$ID=$($objectFileName -match "\d+" > $null;$matches[0])
				$LogFile = "$LogFolder\Error_compile_$objectFileName"
				$importFile = "$NavisionCodeLocation\$objectType\$objectFileName"
				$Type=Get-NAVObjectTypeIdFromName($objectType)
				
				if (Test-Path "$Logfolder\navcommandresult.txt") 
					{
						Remove-Item "$Logfolder\navcommandresult.txt"
					}				

				Write-Host "Compilation of object with [ID]=$ID and Type=$Type started" -ForegroundColor Yellow			
				$finSqlCommand = """$NAVFolder\finsql.exe"" command=compileobjects,file=$ExportFile,servername=$Server,database=$Database,synchronizeschemachanges=force,Logfile=$LogFile, navservername=TTRAFLOCO2K910, navserverinstance=$Database, navservermanagementport=7031, filter=Type=$objecttype;ID=$ID"
				Write-Debug $finSqlCommand
				cmd /c $finSqlCommand
				if (Test-Path $LogFile) 
					{   
						Write-Host "Compilation of object with [ID]=$ID and Type=$Type failed.. Please check log for more detail" -ForegroundColor Red 
						Write-Host "--------------------------------------------------------------------------------------------" -ForegroundColor Red
						cat $LogFile
						Write-Host "--------------------------------------------------------------------------------------------" -ForegroundColor Red
						$ImpCompFlag="F"
					}
				else
					{        
						Write-Host "Object with [ID]=$ID and Type=$Type Compiled successfully" -ForegroundColor Green
						#Updating [Version List] value of the imported object in Navision
						$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
						$sqlConnection.Open()
						$sqlCommand = $sqlConnection.CreateCommand()
						$sqlCommand.CommandText ="update Object set [Version List]='$versionlist C$LatestChSet' where [Type]=$type and [ID]=$ID"  
						$sqlReader = $sqlCommand.ExecuteReader()
						$sqlConnection.Close()																
					}						
			}
				
		if ($ImpCompFlag -eq "F")
			{				
				Write-Host "There are one or more compilation errors encountered while compiling the imported objects into Navision" -ForegroundColor Red
				Write-Host "Please check the logs at $LogFolder for more information....." -ForegroundColor Red
				if ($dayZero -eq "T")
					{
						if (Test-Path ${SuccessVerFile}) 
							{	
								Remove-Item "${SuccessVerFile}" -Force
							}	
					}
				Write-Host "Build Failed" -ForegroundColor Red
				[int] $global:flag_fail = 0 
				#echo $FinalChangeSet >> $SuccessVerFile
				exit 1
				
			}
		else 
			{
				Write-Host "Compilation of all the imported objects completed sucessfully" -ForegroundColor Green			
			}
									
		# Create and open a database connection
		$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
		$sqlConnection.Open()
		#Create a command object
		$sqlCommand = $sqlConnection.CreateCommand()
		$sqlCommand.CommandText ="select count(*) Result from Object where [Version List]='$versionlist C$LatestChSet'"  
		#Execute the Command
		$sqlReader = $sqlCommand.ExecuteReader()
		#Parse the records
		while ($sqlReader.Read())
		{ 
			$validVersionList=$sqlReader["Result"]
		} 
		# Close the database connection
		$sqlConnection.Close()

		echo "There are $validVersionList objects having [Version List]=${versionlist} C$LatestChSet"	
		if (${validVersionList} -eq 0)
			{
				Write-Host "No object found in Navision having Version list as ${versionlist} C$LatestChSet" -ForegroundColor Red
				if ($dayZero -eq "T")
					{
						if (Test-Path ${SuccessVerFile}) 
							{	
								Remove-Item "${SuccessVerFile}" -Force
							}	
					}
				Write-Host "Build Failed" -ForegroundColor Red
				[int] $global:flag_fail = 0 
				echo $FinalChangeSet >> $SuccessVerFile
				exit 1
			}		
		
		$LogFile ="$LogFolder\Error_export_$versionlist.txt"
		
		if (Test-Path "$LogFolder\navcommandresult.txt")
			{
				Remove-Item "$LogFolder\navcommandresult.txt" -Force			
			}	
		$finSqlCommand = """$NAVFolder\finsql.exe"" command=exportobjects,file=$fobbuildfile,servername=$Server,database=$Database,Logfile=$LogFile, navservername=TTRAFLOCO2K910, navserverinstance=$Database, navservermanagementport=7031, filter=Version List='$versionlist C$LatestChSet'"
		echo $finSqlCommand
		cmd /c $finSqlCommand
		if (Test-Path "$LogFolder\navcommandresult.txt")
			{
				Type "$LogFolder\navcommandresult.txt"
			}	
		if (!(Test-Path -Path $LogFolder\Error_*.txt))
			{
				if (Test-Path "$fobbuildfile")
					{
						
						certutil -hashfile ${fobbuildfile} | ?{!($_ | select-string "hash")} > $md5File
						Copy-Item -Path "${fobbuildfile}" "${rmfobfile}" -recurse -Force

					}
				
				Write-Host "Build Successful" -ForegroundColor Green
				
				clear-content $SuccessVerFile
			}
		else 
			{				
				if ($dayZero -eq "T")
					{
						if (Test-Path ${SuccessVerFile}) 
							{	
								#Remove-Item "${SuccessVerFile}" -Force
							}	
					}
				Write-Host "Build Failed" -ForegroundColor Red
				[int] $global:flag = 0
				#echo $FinalChangeSet >> $SuccessVerFile
				exit 1
			}
			
		echo "Exiting in the end: Good Bye"
		[int] $global:flag_success = 1
		exit 0	
}	 

echo "Executing MakeBuild Function"
echo "Latest ChangeSet is : $LatestChSet"
MakeBuild -Database $Database -Server $Server -Changesets $chArr

##############################################################################################################
