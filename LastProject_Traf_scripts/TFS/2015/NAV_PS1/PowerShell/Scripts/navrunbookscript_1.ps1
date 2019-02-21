###########################################################
#
# Description: Compile and build Navision for Env Refresh
#
# Author:      Tushar Meshram
#
############################################################

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
$string = $(Get-Content "$scriptPath\..\Config\QA\Configuration.txt" | Select-String $variable).ToString().split("=")[1]
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


##### Variables defined #####

$Server=Valfromconfig 'Dev_DBServer'
$Database=Valfromconfig 'Dev_Database'
$NavisionCodeLocation="$scriptPath\..\..\NavWorkspace"
$versionlist="${Env:BUILD_BUILDNUMBER}"
$NAVFolder=Valfromconfig 'RTC Client Path'
$LogFile="$NavisionCodeLocation\log.log"
$fobbuildfile="$NavisionCodeLocation\$versionlist.fob"
$FullLogfile="$NavisionCodeLocation\fulllog.log"
$LogFolder="$NavisionCodeLocation"
$objexcludeArray=(Valfromconfig 'ObjExcludeList').split("|")
$artifactdir="$scriptPath\..\..\artifact"

######################## Copying from Full build ###############################
#####  Full Compilation ######
$starttime = Get-Date
Write-Host "Full Compilation Start time " $starttime

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
					}	
$datetime = Get-Date
Write-Host "Full Compilation End time " $datetime
					
#### End of Full Compilation  ####


################### Logic for the getting all the files under NavWorkspace and update the Version List , Update the exclusion List and delete the rest ################

	$objDirs=(dir -Directory -path ${NavisionCodeLocation}).name

		foreach ($objectType in $objDirs)
					{						
						$objArray=(dir -File -path ${NavisionCodeLocation}\$objectType).Name
						cd $NavisionCodeLocation\$objectType

						#Excluding the objects inside $objArray which are in $objexcludeArray
						${objexcludeArray}|%{ ${objArray}=${objArray} -ne $_ }

						$objectType_var= @()	

						#echo ${objArray} > $NavisionCodeLocation\$objectType\objarray.log
$datetime = Get-Date
Write-Host "Import and Compile Start time " $datetime
		foreach ($objectFileName in $objArray)
						{
									$ID=$($objectFileName -match "\d+" > $null;$matches[0])
										$objectType_var+= $ID
										$UpdateFile = $objectType_var -join "','"
										$UpdateFile = "'" + $UpdateFile + "'"
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
									#Performing Compilation of the object which are Successfully imported into Navision		
									
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
								}
			
						}
$datetime = Get-Date
Write-Host "Import and Compile End time " $datetime

$datetime = Get-Date
Write-Host "Update Version List Start time " $datetime

		if ($ImpCompFlag -eq "F")
				{				
					Write-Host "There are one or more import/compilation errors encountered while importing the objects into Navision since ImportComplieFlag is False" -ForegroundColor Red
					Write-Host "Please check the logs at $LogFolder for more information....." -ForegroundColor Red
					Write-Host "Build Failed" -ForegroundColor Red
					exit 1
				}

							foreach ($objectType in $objDirs)
								{
									#cd $objectType
									$objArray=(dir -File -path ${NavisionCodeLocation}\$objectType).Name
									
									#Excluding the objects inside $objArray which are in $objexcludeArray
									${objexcludeArray}|%{ ${objArray}=${objArray} -ne $_ }
									$objectType_var= @()	
									foreach ($objectFileName in $objArray)
											{
													$ID=$($objectFileName -match "\d+" > $null;$matches[0])
													$objectType_var+= $ID
													$UpdateFile = $objectType_var -join "','"
													$UpdateFile = "'" + $UpdateFile + "'"
											}
													$UpdateFile > $NavisionCodeLocation\$objectType\file.txt
													
													
								}
}

	cd $NavisionCodeLocation

							$codeunitobj=Get-Content $NavisionCodeLocation\Codeunit\file.txt
							$reporttobj=Get-Content $NavisionCodeLocation\Report\file.txt
							$menusuiteobj=Get-Content $NavisionCodeLocation\MenuSuite\file.txt
							$queryobj=Get-Content $NavisionCodeLocation\Query\file.txt
							$tableobj=Get-Content $NavisionCodeLocation\Table\file.txt
							$xmlportobj=Get-Content $NavisionCodeLocation\XMLPort\file.txt
							$pageobj=Get-Content $NavisionCodeLocation\Page\file.txt
							$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
							$sqlConnection.Open()
							$sqlCommand = $sqlConnection.CreateCommand()
							$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
							$sqlConnection.Open()
								$sqlCommand = $sqlConnection.CreateCommand()
								#Updating [Version List] value of the imported object in Navision
								$sqlCommand.CommandText ="update Object set [Version List]='$versionlist' where [Type]=5 and [ID] In ( $codeunitobj );
									update Object set [Version List]='$versionlist' where [Type]=3 and [ID] In ( $reporttobj );
									update Object set [Version List]='$versionlist' where [Type]=7 and [ID] In ( $menusuiteobj );
									update Object set [Version List]='$versionlist' where [Type]=9 and [ID] In ( $queryobj );
									update Object set [Version List]='$versionlist' where [Type]=1 and [ID] In ( $tableobj );
									update Object set [Version List]='$versionlist' where [Type]=6 and [ID] In ( $xmlportobj );
									update Object set [Version List]='$versionlist' where [Type]=8 and [ID] In ( $pageobj );"  
								$sqlReader = $sqlCommand.ExecuteReader()
								$sqlConnection.Close()

	$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
	$sqlConnection.Open()
	$sqlCommand = $sqlConnection.CreateCommand()
	$sqlCommand.CommandText ="update Object set [Version List]='Exclusion Object' where Type=7 and ID =1010;
	update Object set [Version List]='Exclusion Object' where Type=5 and ID in (11102070,11102072,71107,14074213,14074616, 71116,71126,71145,71124,71128,71166,71168);
	update Object set [Version List]='Exclusion Object' where Type=8 and ID in (11175819,675,681,875,1395,1396,5540,11175795);
	update Object set [Version List]='Exclusion Object' where Type=1 and ID=14074208;"
	$sqlReader = $sqlCommand.ExecuteReader()
	$sqlConnection.Close()
#delete  from [Object] where [Version List]!='ExclusionObjects' and [Version List]!='Updating_35';

$datetime = Get-Date
Write-Host "Udate Version List End time " $datetime

$datetime = Get-Date
Write-Host "Export Objects start time " $datetime

$finSqlCommand = """$NAVFolder\finsql.exe"" command=exportobjects,file=$fobbuildfile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Version List='$versionlist', navservername=TTRAFLOCO2K910, navserverinstance=NAVDEMO, navservermanagementport=7049"
Write-Debug $finSqlCommand
cmd /c $finSqlCommand

$datetime = Get-Date
Write-Host "Export Objects End time " $datetime

######## Zip Master Config file ############
Add-Type -Assembly "System.IO.Compression.FileSystem" ;
[System.IO.Compression.ZipFile]::CreateFromDirectory("$scriptPath\..\..\Master_Config_Package","$artifactdir\Master_Config_Package.zip")
Copy-Item -path "$fobbuildfile"  -Destination "$artifactdir" -Container -force -recurse

