#####################################################################################
#																				   	#
# Description: PowerShell Script to create full build in Navision				 	#
#																				   	#
# Author:      Tushar Meshram														#
#																					#				
#####################################################################################
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

$gitPath="C:\Program Files\Git\cmd"
$NAVFolder=Valfromconfig 'RTC Client Path'
$env:PATH += ";${gitPath};${NAVFolder}"
$BldChngSetFolder="C:\ePuma_Prod\Build-Changeset"
$LogFolder="$scriptPath\..\Build-Logs-Full"
$NavisionCodeLocation="$scriptPath\..\..\NavWorkspace"
$versionlist="${Env:BUILD_BUILDNUMBER}"
$artifactdir="$scriptPath\..\..\artifact"
$fobbuildfile="$artifactdir\${Env:BUILD_DEFINITIONNAME}.fob"
$rmfobfile="${versionlist}\RM.fob"
$deployscript="${scriptPath}\rm_deploy_full.ps1"
$Versionupdate="${Env:BUILD_BUILDNUMBER}"

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

if (!(Test-Path -Path $BldChngSetFolder ))
	{
		echo "Directory $BldChngSetFolder does Not Exists"
		New-Item -ItemType directory -Path $BldChngSetFolder
		echo "Created Directory $BldChngSetFolder"
	}

<# if (!(Test-Path -Path $BldDrop ))
	{
		echo "Directory $BldDrop does Not Exists"
		New-Item -ItemType directory -Path $BldDrop
		echo "Created Directory $BldDrop"
	} #>

#New-Item -ItemType directory -Path $BldDrop\${versionlist} -force
#New-Item -ItemType directory -Path $BldDrop\${versionlist}\Master_Config_Package -force
#New-Item -ItemType directory -Path $BldDrop\${versionlist}\Automation_input_xml -force

################
# Fob logic here
################
function MakeBuild()
{
		
####  Full Compilation ######

				$FullLogFile = "$LogFolder\Full_Error_compile.txt"

				if (Test-Path "$Logfolder\navcommandresult.txt") 
					{
						Remove-Item "$Logfolder\navcommandresult.txt"
					}				

				Write-Host "Full Compilation started" -ForegroundColor Yellow
				$finSqlCommand = """$NAVFolder\finsql.exe"" command=compileobjects,servername=$Server,database=$Database,synchronizeschemachanges=force,Logfile=$FullLogFile, navservername=TTRAFLOCO2K910, navserverinstance=$Database, navservermanagementport=7031"
				Write-Debug $finSqlCommand
				cmd /c $finSqlCommand
				if (Test-Path $FullLogFile) 
					{   
						Write-Host "Some Compilation errors for full compilation. Check log for more detail" -ForegroundColor Red
						Write-Host "--------------------------------------------------------------------------------------------" -ForegroundColor Red
						Write-Host "--------------------------------------------------------------------------------------------" -ForegroundColor Red
					}
						
#### End of Full Compilation  ####


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
				#### Ignoring TAG
				$num = [int]$ID
	#			if ( ($Type -eq 5 -and $num -ge 14074200 -and $num -le 14074699) -or ( $Type -eq 1 -and $num -ge 14074200 -and $num -le 14074699 ) -or ($Type -eq 3 -and $num -ge 14074200 -and $num -le 14074699) -or ($Type -eq 6 -and $num -ge 14074200 -and $num -le 14074204) -or ($Type -eq 7 -and $num -eq 1056) -or ($Type -eq 8 -and $num -ge 14074200 -and $num -le 14075199))
				if ( ($Type -eq 5 -and $num -ge 14074200 -and $num -le 14074699) -or ( $Type -eq 1 -and $num -ge 23053000 -and $num -le 23053999 ) -or ( $Type -eq 1 -and $num -ge 14074200 -and $num -le 14074699) -or ($Type -eq 3 -and $num -ge 14074200 -and $num -le 14074699) -or ($Type -eq 6 -and $num -ge 14074200 -and $num -le 14074204) -or ($Type -eq 7 -and $num -eq 1056) -or ($Type -eq 8 -and $num -ge 14074200 -and $num -le 14075199) -or ($Type -eq 8 -and $num -ge 23053000 -and $num -le 23053999)) 
					{	
							write-host "Ignoring Import for $Type and Object $num"
					}
				else		
					{		
							$finSqlCommand = """$NAVFolder\finsql.exe"" command=importobjects,file=$importFile,servername=$Server,database=$Database,synchronizeschemachanges=force,importaction=overwrite,Logfile=$LogFile, navservername=TTRAFLOCO2K910, navserverinstance=$Database, navservermanagementport=7031,filter=Type=$objecttype;ID=$ID"
							Write-Debug $finSqlCommand
							cmd /c $finsqlCommand
					}
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
									$finSqlCommand = """$NAVFolder\finsql.exe"" command=compileobjects,file=$ExportFile,servername=$Server,database=$Database,Logfile=$LogFile, navservername=TTRAFLOCO2K910, navserverinstance=$Database, navservermanagementport=7031,filter=Type=$objecttype;ID=$ID"
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
											$sqlCommand.CommandText ="update Object set [Version List]='$Versionupdate' where [Type]=$type and [ID]=$ID"  
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
	$sqlCommand.CommandText ="select count(*) Result from Object where [Version List]='$Versionupdate'"  
	#Execute the Command
	$sqlReader = $sqlCommand.ExecuteReader()
	#Parse the records
	while ($sqlReader.Read())
	{ 
		$validVersionList=$sqlReader["Result"]
	} 
	# Close the database connection
	$sqlConnection.Close()				
				
	echo "There are $validVersionList objects having [Version List]=${Versionupdate}"
		
	if (${validVersionList} -eq 0)
		{
			Write-Host "No object found in Navision having Version list as ${Versionupdate}" -ForegroundColor Red
			Write-Host "Build Failed" -ForegroundColor Red
			exit 1
		}					
				
	$LogFile ="$LogFolder\Error_export_$Versionupdate.txt"		

	if (Test-Path "$LogFolder\navcommandresult.txt")
		{
			Remove-Item "$LogFolder\navcommandresult.txt" -Force			
		}		

	#New-Item -ItemType directory -Path ${BldDateFolder}	
	$finSqlCommand = """$NAVFolder\finsql.exe"" command=exportobjects,file=$fobbuildfile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Version List='$Versionupdate', navservername=TTRAFLOCO2K910, navserverinstance=$Database, navservermanagementport=7031" 
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
						
#						certutil -hashfile ${fobbuildfile} | ?{!($_ | select-string "hash")} > $md5File
	#					Copy-Item -Path "${fobbuildfile}" "${rmfobfile}" -recurse -Force
						#Copy-Item -Path "${deployscript}" "${BldDrop}" -recurse -Force
						Copy-Item -path "${scriptPath}/../../Master_Config_Package/"  -Destination "$artifactdir" -Container -force -recurse
						Copy-Item -path "${scriptPath}/../../Automation_input_xml/"  -Destination "$artifactdir" -Container -force -recurse
						Copy-Item -path "${scriptPath}/../../Automation_input_xml/automation_xml_input.txt"  -Destination "$artifactdir" -Container -force -recurse

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