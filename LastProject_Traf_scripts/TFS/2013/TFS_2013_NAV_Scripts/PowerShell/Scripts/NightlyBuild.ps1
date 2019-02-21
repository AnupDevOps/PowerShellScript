
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
$string = $(Get-Content "$scriptPath\..\Config\Configuration.txt" | Select-String $variable).ToString().split("=")[1]
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

$TfPath=Valfromconfig 'TFS Folder Path'
$NAVFolder=Valfromconfig 'RTC Client Path'
$env:PATH += ";${TfPath};${NAVFolder}"
#$BldChngSetFolder="C:\ePuma_Prod\Build-Changeset"
$BldDrop="${Env:TF_BUILD_DROPLOCATION}"
$LogFolder="$scriptPath\..\Build-Logs-Full"
$NavisionCodeLocation="$scriptPath\..\..\NavWorkspace"
#$SuccessVerFullFile="$BldChngSetFolder\SuccessVersionMasterFull.txt"
#$SuccessVerIncrFile="$BldChngSetFolder\SuccessVersionIncrMaster.txt"
$versionlist="${Env:TF_BUILD_BUILDNUMBER}"
$BldDateFolder="${BldDrop}\${versionlist}"
$fobbuildfile="${BldDrop}\${versionlist}\$versionlist.fob"
$rmfobfile="${BldDrop}\RM.fob"
$deployscript="${scriptPath}\rm_deploy_PR_FULL.ps1"
$FinalLatestFob="${BldDrop}\..\..\LatestFob\Latest.fob"

$md5File="${BldDrop}\${versionlist}\md5_${versionlist}.txt"
$Server=Valfromconfig 'Dev_DBServer'
$Database=Valfromconfig 'Dev_Database'
$navSrvPath=Valfromconfig 'serverWorkSpacePath'
$tfsCollection=Valfromconfig 'tfsCollectionURL'
$objexcludeArray=(Valfromconfig 'ObjExcludeList').split("|")

Write-Host "The script name is $scriptName" -ForegroundColor Yellow
Write-Host "The script path is $scriptPath" -ForegroundColor Yellow
Write-Host "`n#####Script ${scriptName} Started#####`n"	-ForegroundColor Yellow
Write-Host "LogFolder is ${LogFolder}`n" -ForegroundColor Yellow
Write-Host "NavisionCodeLocation is ${NavisionCodeLocation}`n" -ForegroundColor Yellow

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



if (!(Test-Path -Path $BldDrop ))
	{
		echo "Directory $BldDrop does Not Exists"
		New-Item -ItemType directory -Path $BldDrop
		echo "Created Directory $BldDrop"
	}

			
	

################
# Fob logic here
################
function MakeBuild()
{
	
	#Setting Import and Compile Flag initially as True
	$ImpCompFlag="T"

	$objDirs=(dir -Directory -path ${NavisionCodeLocation}).name
	
	foreach ($objectType in $objDirs)
			{						
				$objArray=(dir -File -path ${NavisionCodeLocation}\$objectType).Name

				#Excluding the objects inside $objArray which are in $objexcludeArray
				${objexcludeArray}|%{ ${objArray}=${objArray} -ne $_ }

				foreach ($objectFileName in $objArray)
						{
							$ID=$($objectFileName -match "\d+" > $null;$matches[0])
							$LogFile = "$LogFolder\Error_import_$objectFileName"
							$importFile = "$NavisionCodeLocation\$objectType\$objectFileName"							
							$Type=Get-NAVObjectTypeIdFromName($objectType)
							if (Test-Path "$Logfolder\navcommandresult.txt") 
								{
									Remove-Item "$Logfolder\navcommandresult.txt"
								}						
							$finSqlCommand = """$NAVFolder\finsql.exe"" command=importobjects,file=$importFile,servername=$Server,database=$Database,synchronizeschemachanges=force,importaction=overwrite,Logfile=$LogFile, navservername=TTRAFLOCO2K910, navserverinstance=NAVDEMO, navservermanagementport=7049,filter=Type=$objecttype;ID=$ID"
							Write-Debug $finSqlCommand
							cmd /c $finsqlCommand
							if (Test-Path $LogFile)
								{
									Echo "Error in import for $importFile.Please Check $LogFile for more Details"
									$ImpCompFlag="F"										
								}
							else 
								{											
									Write-Host "Object with [ID]=$ID and Type=$Type Imported sucessfully" -ForegroundColor Green
									#Performing Compilation of the object which is imported into Navision				
									$LogFile = "$LogFolder\Error_compile_$objectFileName"

									if (Test-Path "$Logfolder\navcommandresult.txt") 
										{
											Remove-Item "$Logfolder\navcommandresult.txt"
										}
									Write-Host "Compilation of object with [ID]=$ID and Type=$Type started" -ForegroundColor Yellow
									$finSqlCommand = """$NAVFolder\finsql.exe"" command=compileobjects,file=$ExportFile,servername=$Server,database=$Database,Logfile=$LogFile, navservername=TTRAFLOCO2K910, navserverinstance=NAVDEMO, navservermanagementport=7049,filter=Type=$objecttype;ID=$ID"
									Write-Debug $finSqlCommand
									cmd /c $finSqlCommand
									
									if (Test-Path $LogFile) 
										{   
											Write-Host "Compilation of object with [ID]=$ID and Type=$Type failed.. Please check log for more detail" -ForegroundColor Red 
											$ImpCompFlag="F"
										}
									else
										{        
											Write-Host "Object with [ID]=$ID and Type=$Type Compiled sucessfully" -ForegroundColor Green
											#Updating [Version List] value of the imported object in Navision
											$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
											$sqlConnection.Open()
											$sqlCommand = $sqlConnection.CreateCommand()
											$sqlCommand.CommandText ="update Object set [Version List]='$versionlist' where [Type]=$type and [ID]=$ID"  
											$sqlReader = $sqlCommand.ExecuteReader()
											$sqlConnection.Close()																
										}				 			
								}		
						}
			}
		
	if ($ImpCompFlag -eq "F")
		{				
			Write-Host "There are one or more import/compilation errors encountered while importing the objects into Navision since ImportComplieFlag is False" -ForegroundColor Red
			Write-Host "Please check the logs at $LogFolder for more information....." -ForegroundColor Red
			Write-Host "Build Failed" -ForegroundColor Red
			exit 1
		}
				
	# Create and open a database connection
	$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
	$sqlConnection.Open()
	#Create a command object
	$sqlCommand = $sqlConnection.CreateCommand()
	$sqlCommand.CommandText ="select count(*) Result from Object where [Version List]='$versionlist'"  
	#Execute the Command
	$sqlReader = $sqlCommand.ExecuteReader()
	#Parse the records
	while ($sqlReader.Read())
	{ 
		$validVersionList=$sqlReader["Result"]
	} 
	# Close the database connection
	$sqlConnection.Close()				
				
	echo "There are $validVersionList objects having [Version List]=${versionlist}"
		
	if (${validVersionList} -eq 0)
		{
			Write-Host "No object found in Navision having Version list as ${versionlist}" -ForegroundColor Red
			Write-Host "Build Failed" -ForegroundColor Red
			exit 1
		}					
				
	$LogFile ="$LogFolder\Error_export_$versionlist.txt"		

	if (Test-Path "$LogFolder\navcommandresult.txt")
		{
			Remove-Item "$LogFolder\navcommandresult.txt" -Force			
		}		

####  Full Compilation ######

				$FullLogFile = "$LogFolder\Full_Error_compile.txt"

				if (Test-Path "$Logfolder\navcommandresult.txt") 
					{
						Remove-Item "$Logfolder\navcommandresult.txt"
					}				

				Write-Host "Full Compilation started" -ForegroundColor Yellow
				$finSqlCommand = """$NAVFolder\finsql.exe"" command=compileobjects,servername=$Server,database=$Database,synchronizeschemachanges=force,Logfile=$FullLogFile, navservername=TTRAFLOCO2K910, navserverinstance=NAVDEMO, navservermanagementport=7049"
				Write-Debug $finSqlCommand
				cmd /c $finSqlCommand
				if (Test-Path $FullLogFile) 
					{   
						Write-Host "Some Compilation errors for full compilation. Check log for more detail" -ForegroundColor Red
						Write-Host "--------------------------------------------------------------------------------------------" -ForegroundColor Red
						Write-Host "--------------------------------------------------------------------------------------------" -ForegroundColor Red
					}
				else
					{        
						Write-Host "Full Compilation completed successfully" -ForegroundColor Green
						$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
						$sqlConnection.Open()
						$sqlCommand = $sqlConnection.CreateCommand()
						$sqlReader = $sqlCommand.ExecuteReader()
						$sqlConnection.Close()																
					}						
#### End of Full Compilation  ####

	New-Item -ItemType directory -Path ${BldDateFolder}	
	$finSqlCommand = """$NAVFolder\finsql.exe"" command=exportobjects,file=$fobbuildfile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Version List='$versionlist', navservername=TTRAFLOCO2K910, navserverinstance=NAVDEMO, navservermanagementport=7049" 
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
						#Copy-Item -Path "${fobbuildfile}" "${FinalLatestFob}" -recurse -Force
						Copy-Item -Path "${deployscript}" "${BldDrop}" -recurse -Force
					}

			Write-Host "Build Successful" -ForegroundColor Green
			
		}
	else 
		{				
			Write-Host "There are one or more import/compilation/export errors encountered while importing/exporting the objects into Navision" -ForegroundColor Red
			Write-Host "Please check the logs at $LogFolder for more information....." -ForegroundColor Red
			Write-Host "Build Failed" -ForegroundColor Red
			exit 1
		}
			
	echo "Exiting in the end: Good Bye"
	exit 0
} 

########
##Main Logic here
########
#Changing the current path to NavisionCodeLocation	
Set-Location -Path "${NavisionCodeLocation}"
MakeBuild

##############################################################################################################









