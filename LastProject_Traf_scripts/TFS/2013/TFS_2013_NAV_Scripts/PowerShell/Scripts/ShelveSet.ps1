## Script for On Merge Build

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
$BldChngSetFlFolder="$scriptPath\..\Build-ChangesetFiles"
$BldDrop="${Env:TF_BUILD_DROPLOCATION}"
$LogFolder="$scriptPath\..\Build-Logs"
$NavisionCodeLocation="$scriptPath\..\..\NavWorkspace"
$versionlist="${Env:TF_BUILD_BUILDNUMBER}"
$BuildChngSetInfoFl="${BldDrop}\${versionlist}_ChangeSet.txt"
$BldDateFolder="${BldDrop}\${versionlist}"
$fobbuildfile="${BldDrop}\${versionlist}\$versionlist.fob"
$rmfobfile="${BldDrop}\RM.fob"
$deployscript="${scriptPath}\rm_deploy.ps1"
$FinalLatestFob="${BldDrop}\..\..\LatestFob\Latest.fob"
$md5File="${BldDrop}\${versionlist}\md5_${versionlist}.txt"
$Server=Valfromconfig 'Dev_DBServer'
$Database=Valfromconfig 'Dev_Database'
$navSrvPath=Valfromconfig 'serverWorkSpacePath'
$tfsCollection=Valfromconfig 'tfsCollectionURL'
Write-Host "The script name is $scriptName" -ForegroundColor Yellow
Write-Host "The script path is $scriptPath" -ForegroundColor Yellow
Write-Host "`n#####Script ${scriptName} Started#####`n"	-ForegroundColor Yellow
Write-Host "LogFolder is ${LogFolder}`n" -ForegroundColor Yellow
Write-Host "NavisionCodeLocation is ${NavisionCodeLocation}`n" -ForegroundColor Yellow

	if (!(Test-Path -Path $BldDrop ))
		{
			echo "Directory $BldDrop does Not Exists"
			New-Item -ItemType directory -Path $BldDrop
			echo "Created Directory $BldDrop"
		}
	 
	 echo $null > $BuildChngSetInfoFl

	Set-Location -Path "${NavisionCodeLocation}"

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
 
#########################################
 function MakeBuild
{
[CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server
	)


	# Get all the shelvesets started with name Gated
	tf shelvesets /collection:http://ttraflon2k932:8080/tfs/puma /owner:* | Select-String ^Gated* > $LogFolder\shelvesets_name.txt
	
	# Remove first blank line
	(gc $LogFolder\shelvesets_name.txt) | ? {$_.trim() -ne "" } > $LogFolder\shelvesets_name.txt
	
	# Get the actual gated build name
	get-content "$LogFolder\shelvesets_name.txt" | select  -last 1 > $LogFolder\shelvesets_single_name.txt
	$current_shelveset=$(cat $LogFolder\shelvesets_single_name.txt).split(" ")[0] 
	
	# Get the Username who initiated the Gated Checkin
	$current_user=Get-Content $LogFolder\shelvesets_single_name.txt | Foreach {"$(($_ -split '\s+',4)[1..2])"}
	
	# Remove the spaces and add . between Uername 
	$current_user = $current_user -replace '\s','.'

	tf status /shelveset:"$current_shelveset;$current_user" > $LogFolder\shelvesets_content.txt
	$ChangeData = $(Get-Content $LogFolder\shelvesets_content.txt)
	$validObjects=$($ChangeData -match "^[a-zA-Z]+_\d+\.txt") 

	$validObjects | %{$_.split(" ")[0]} > $BuildChngSetInfoFl

	$validObjects=$validObjects | %{$_.split(" ")[0]}

		#Setting the Flag initially as True
		$ImpCompFlag="T"

		foreach ($objFl in $validObjects)
			{
				$objectType=$objFl.split("_")[0]
				$ID=$($objFl -match "\d+" > $null;$matches[0])
				$LogFile = "$LogFolder\Error_import_$objFl"
				$importFile = "$NavisionCodeLocation\$objectType\$objFl"
				$Type=Get-NAVObjectTypeIdFromName($objectType)
				if (Test-Path "$Logfolder\navcommandresult.txt") 
					{
						Remove-Item "$Logfolder\navcommandresult.txt"
					}
				$finSqlCommand = """$NAVFolder\finsql.exe"" command=importobjects,file=$importFile,servername=$Server,database=$Database,synchronizeschemachanges=force,importaction=overwrite,Logfile=$LogFile,filter=Type=$objecttype;ID=$ID"
				Write-Debug $finSqlCommand
				cmd /c $finsqlCommand
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
				Write-Host "Build Failed" -ForegroundColor Red
				exit 1
			}
		else 
			{
				Write-Host "Import of all the objects completed sucessfully" -ForegroundColor Green			
			}
			
			
		#Performing Compilation of the objects which are imported into Navision			
		#Setting the Flag initially as True
		$ImpCompFlag="T"
		
####  Full Compilation ######

				$LogFile = "$LogFolder\Full_Error_compile.txt"

				if (Test-Path "$Logfolder\navcommandresult.txt") 
					{
						Remove-Item "$Logfolder\navcommandresult.txt"
					}				

				Write-Host "Full Compilation started" -ForegroundColor Yellow
				$finSqlCommand = """$NAVFolder\finsql.exe"" command=compileobjects,servername=$Server,database=$Database,synchronizeschemachanges=force,Logfile=$LogFile"
				Write-Debug $finSqlCommand
				cmd /c $finSqlCommand
				if (Test-Path $LogFile) 
					{   
						Write-Host "Compilation of object failed.. Please check log for more detail" -ForegroundColor Red
						Write-Host "--------------------------------------------------------------------------------------------" -ForegroundColor Red
						Write-Host "--------------------------------------------------------------------------------------------" -ForegroundColor Red
						$ImpCompFlag="F"
					}
				else
					{        
						Write-Host "Compilation completed successfully" -ForegroundColor Green
						$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
						$sqlConnection.Open()
						$sqlCommand = $sqlConnection.CreateCommand()
						$sqlReader = $sqlCommand.ExecuteReader()
						$sqlConnection.Close()																
					}						
#### End of Full Compilation  ####


#### Start of Incremental Compilation #####
		foreach ($objFl in $validObjects)
			{
				$objectType=$objFl.split("_")[0]
				$ID=$($objFl -match "\d+" > $null;$matches[0])
				$LogFile = "$LogFolder\Error_compile_$objFl"
				$importFile = "$NavisionCodeLocation\$objectType\$objFl"
				$Type=Get-NAVObjectTypeIdFromName($objectType)
				
				if (Test-Path "$Logfolder\navcommandresult.txt") 
					{
						Remove-Item "$Logfolder\navcommandresult.txt"
					}				

				Write-Host "Compilation of object with [ID]=$ID and Type=$Type started" -ForegroundColor Yellow
				$finSqlCommand = """$NAVFolder\finsql.exe"" command=compileobjects,file=$importFile,servername=$Server,database=$Database,synchronizeschemachanges=force,Logfile=$LogFile,filter=Type=$objecttype;ID=$ID"
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
						$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
						$sqlConnection.Open()
						$sqlCommand = $sqlConnection.CreateCommand()
						$sqlCommand.CommandText ="update Object set [Version List]='$versionlist' where [Type]=$type and [ID]=$ID"  
						$sqlReader = $sqlCommand.ExecuteReader()
						$sqlConnection.Close()																
					}						
			}
#### End of Incremental Compilation #####

#### Exit if compilation error #####
		if ($ImpCompFlag -eq "F")
			{				
				Write-Host "There are one or more compilation errors encountered while compiling the imported objects into Navision" -ForegroundColor Red
				Write-Host "Please check the logs at $LogFolder for more information....." -ForegroundColor Red
				Write-Host "Build Failed" -ForegroundColor Red
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

		New-Item -ItemType directory -Path ${BldDateFolder}	
		$finSqlCommand = """$NAVFolder\finsql.exe"" command=exportobjects,file=$fobbuildfile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Version List='$versionlist'" 
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
						Copy-Item -Path "${fobbuildfile}" "${FinalLatestFob}" -recurse -Force 
						Copy-Item -Path "${deployscript}" "${BldDrop}" -recurse -Force 
					}
				mv ${BuildChngSetInfoFl} ${BldDateFolder}
				Write-Host "Build Successful" -ForegroundColor Green
			}
		else 
			{				
				Write-Host "Build Failed" -ForegroundColor Red
				exit 1
			}
			
		echo "Exiting in the end: Good Bye"
		exit 0	
}	 

echo "Executing MakeBuild Function"
echo "Latest ChangeSet is : $LatestChSet"
MakeBuild -Database $Database -Server $Server

##############################################################################################################			
