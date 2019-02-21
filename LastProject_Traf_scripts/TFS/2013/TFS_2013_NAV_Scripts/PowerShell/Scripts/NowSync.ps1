###########################################################
#
# Description: Main Script to Call Nowsync 
#
# Author:      Khushwant Singh
#
# Modified:    Get latest and checkin part
############################################################

param(
        [String]$argument,
        [String]$Type,
        [String]$objectid
  )

$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot  
  
   	echo "Enter the Env you want to work Dev/QADev"
	$env_new= read-host
	 
		if($env_new -eq "DEV" -or  $env_new -eq "dev")
			{
			Copy-Item -path "$profile\..\Dev\configuration.txt" "$profile\..\Config\configuration.txt" -recurse -Force
			
			}	
		if($env_new -eq "QADEV" -or  $env_new -eq "qadev")
			{
			Copy-Item -path "$profile\..\QADev\configuration.txt" "$profile\..\Config\configuration.txt" -recurse -Force
			
			}	
			
echo $env


############################################################
#checking of NAV2015 client path on machine 
############################################################
$TfPath = $(get-content "$profile\..\Config\Configuration.txt"|Select-String 'TFS Folder Path').ToString().split("=")[1]
$env:PATH += ";${TfPath}"

if((Test-Path -Path "C:\Program Files\Microsoft Dynamics NAV\80" ))
{
    Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\80\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -force -DisableNameChecking
    Import-Module 'C:\Program Files\Microsoft Dynamics NAV\80\Service\NavAdminTool.ps1' -DisableNameChecking > $null
    Import-Module "$scriptPath\..\CommonPSFunctions\CommonPSFunctions.psm1" -DisableNameChecking
    Import-Module "$scriptPath\..\CommonPSFunctions\CommonPSFunctionshelp.psm1" -DisableNameChecking  
}
else
{
    Write-Host "Nav 2015 Client path not found.Please Check.................Press any key to exit ..." -ForegroundColor Red
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

$flag=1
$Environment=Valfromconfig 'TFSEnvironment'
$Server=Valfromconfig 'Dev_DBServer'
$Database=Valfromconfig 'Dev_Database'
$NavWorkspace=Valfromconfig 'Workspace Path'
$navSrvPath=Valfromconfig 'serverWorkSpacePath'
$LogFolder=Valfromconfig 'LogFolder'
$tfsCollection=Valfromconfig 'tfsCollectionURL'

if(!(Test-Path -Path $NavWorkspace ))
{
    echo "Workspace=$NavWorkspace does Not Exists... cannot continue"
}
###########################################################
#creation of log folder if not found in local workspace 
###########################################################
if(!(Test-Path -Path $LogFolder ))
{
    echo "Directory $LogFolder does Not Exists"
    New-Item -ItemType directory -Path $LogFolder
    echo "Created Directory $LogFolder"
}

############################################################
#Display the Database of Navision 
############################################################
Write-Host "`nTFS Environment : $Environment" -ForegroundColor Yellow -background Black

############################################################
#Display the Database of Navision 
############################################################
Write-Host "Navision Database : $Database`n" -ForegroundColor Yellow -background Black


############################################################
##Calling of function checkin multiple/single objects of combined type(Value of Navision objects to checkin is read from CombineConfig.ps1 file)
### ./nowsync ci combine 
###
############################################################

if (($argument -eq "ci") -and ($type -eq "combine"))
	{   
		$flag=0
		$combConfigFile="$(split-path $profile)\Config\combineConfig.ps1"
		####Checking if file "CombineConfig.ps1" exits in Config folder
		if (!(Test-Path -Path $combConfigFile))
			{
				Write-Host "File ${combConfigFile} which the command uses is not available.Please Check and try again....Press any key to exit.`n" -ForegroundColor Red
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				exit 0
			}	
		else
			{
				Write-Host "The command will perform the checkin of combined objects as defined in file ${combConfigFile} to TFS..... Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
				$choice = Read-Host
				if ($choice -ne "y")
					{
						Write-Host "`nExited...`n" -ForegroundColor Yellow
						exit 0
					}				
				else
					{							
						####Sourcing upgrade configuration file from C:\upgradeConfig Folder#####
						. ${combConfigFile}
						
						$combArray=$objSequence.split("|")

						$objary=@()
						$objStat="T"
						
					foreach ($Type in $combArray)
						{											
							switch ($Type)
							{     
								"t" {[String]$objectid = $ugTable.trim()}
								"p" {[String]$objectid = $ugPage.trim()}
								"c" {[String]$objectid = $ugCode.trim()}
								"r" {[String]$objectid = $ugReport.trim()}
								"x" {[String]$objectid = $ugXMLport.trim()}
								"q" {[String]$objectid = $ugQuery.trim()}
								"m" {[String]$objectid = $ugMenu.trim()}
							}
						
							$objTypeID=Get-NAVObjectidFromtype $Type
							$objecttype=Get-NAVObjectTypeNameFromId $objTypeID
							
							if ($objectid -eq "")
								{	
									Write-Host "`nNo ${objecttype} objects defined in file $(([io.fileinfo]"${combConfigFile}").Name) to checkin..." -ForegroundColor Yellow
									continue
								}
							
							echo "`n$objecttype Object ids are $objectid"
							$Multi ="No"
							$split = $ObjectID.ToString().split("|")
							
							foreach ($objID in $split)
									{
										NavObjectValidation	-Database $Database -Server $Server -Type $objTypeID -ID $ObjID										
									}
							
							$TFSFolder=Valfromconfig 'TFS Folder Path'
							cd $TFSFolder
							
							$userfile="$LogFolder\checkoutfile.txt"
							$exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive > $userfile"
							cmd /c $exporttfscommand
							$file = Get-Content $userfile
							foreach ($objID in $split)
									{
										$objectname="${objecttype}_${objID}.txt"
										$exporttfscommand ="tf.exe dir ""$navSrvPath/$objecttype/$objectname"" /server:""$tfsCollection"""
										$cmdOutput=$(cmd /c $exporttfscommand)|select-string "No items match"
										if ($cmdOutput)
											{
												UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "add"
												$objary+="${NavWorkspace}\${objecttype}\${objecttype}_${objID}.txt"
											}
										elseif ($(get-content $userfile | select-string edit.*$objectname))
											{						
												UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "Yes"
												$objary+="${NavWorkspace}\${objecttype}\${objecttype}_${objID}.txt"
											}	
										else
											{
												Write-Host "Object $objectname is not Checked out in TFS Workspace" -ForegroundColor Red
												$objStat="F"
											}				
									}
						}
						
						if ($objStat -eq "F") { Write-Host "`nCheck-in to TFS STOPPED due to failures in Objects`n" -ForegroundColor Red; exit 0 }
						echo "The object files to checkin are "
						$objary
						$checkincomments="Check in pending changes for Combined objects"
						$exporttfscommand ="tf.exe checkin $objary /comment:""$checkincomments"""
						cmd /c $exporttfscommand			
						Write-Host "...............Press any key to exit ..." -ForegroundColor Yellow
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
						exit 0				
					}	
			}							
	}
	
############################################################
##Calling of function upgrade checkin (uci) for multiple/single objects of same type(Value of Navision objects to checkout is read from upgradeConfig.ps1 file)
### ./nowsync uci t 
### 
############################################################
  
if (( $argument -eq "uci" -or $argument -eq "UCI" ) -and ($Type -eq "t" -or $Type -eq "p" -or $Type -eq "c" -or $Type -eq "r" -or $Type -eq "x" -or $Type -eq "q" -or $Type -eq "m"))
	{   
		$flag=0
		$objecttype=Get-NAVObjectidFromtype $Type
		$objecttype=Get-NAVObjectTypeNameFromId $objecttype
		$upgConfigFile="$(split-path $profile)\Config\upgradeConfig.ps1"
		####Checking if file "upgradeConfig.ps1" exits in Config folder
		if (!(Test-Path -Path $upgConfigFile))
			{
				Write-Host "File ${upgConfigFile} which the command uses is not available.Please Check and try again....Press any key to exit.`n" -ForegroundColor Red
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				exit 0
			}	
		else
			{
				Write-Host "The command will perform the checkin of ${objecttype} objects as defined in file ${upgConfigFile} to TFS..... Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
				$choice = Read-Host
				if ($choice -ne "y")
					{
						Write-Host "`nExited...`n" -ForegroundColor Yellow
					}				
				else
					{							
						####Sourcing upgrade configuration file from C:\upgradeConfig Folder#####
						. ${upgConfigFile}
						switch ($Type)
						{     
							"t" {[String]$objectid = $ugTable}
							"p" {[String]$objectid = $ugPage}
							"c" {[String]$objectid = $ugCode}
							"r" {[String]$objectid = $ugReport}
							"x" {[String]$objectid = $ugXMLport}
							"q" {[String]$objectid = $ugQuery}
							"m" {[String]$objectid = $ugMenu}
						}
						
						if ($objectid -eq "")
						{
							Write-Host "`nNo ${objecttype} objects defined in file ${upgConfigFile} to checkin....Press any key to exit`n" -ForegroundColor Red
							$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
							exit 0
						}

						$TFSFolder=Valfromconfig 'TFS Folder Path'
						$objTypeID=Get-NAVObjectidFromtype $Type
						$objecttype=Get-NAVObjectTypeNameFromId $objTypeID	   
						$userfile="$LogFolder\checkoutfile.txt" 
						$Multi ="No"
						$split = $ObjectID.ToString().split("|")
						$count = $split.Count

						foreach ($objID in $split)
								{
									NavObjectValidation	-Database $Database -Server $Server -Type $objTypeID -ID $ObjID						
								}

						cd $TFSFolder
						$exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive > $userfile"
						cmd /c $exporttfscommand		
						$file = Get-Content $userfile
						$objary=@()
						$objStat="T"
						foreach ($objID in $split)
								{
									$objectname="${objecttype}_${objID}.txt"									
									$exporttfscommand ="tf.exe dir ""$navSrvPath/$objecttype/$objectname"" /server:""$tfsCollection"""
									$cmdOutput=$(cmd /c $exporttfscommand)|select-string "No items match"
									if ($cmdOutput)
										{
											UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "add"
											$objary+=$objID
										}
									elseif ($(get-content $userfile | select-string edit.*$objectname))
											{						
												UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "Yes"
												$objary+=$objID
											}
									else
										{
											Write-Host "Object $objectname is not Checked out in TFS Workspace" -ForegroundColor Red
											$objStat="F"
										}
								}

						if ($objStat -eq "F") { Write-Host "`nCheck-in to TFS STOPPED due to failures in Objects`n" -ForegroundColor Red; exit 0 }
#						Check in single/multiple files(New and checkout files)
						TFSCheckin -Type $objTypeID -ID $objary				
						Write-Host "...............Press any key to exit ..." -ForegroundColor Yellow
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
						exit 0
					}
			}				
	}

############################################################
##Calling of function upgrade checkout uco for mutiple/single objects (Value of Navision objects to checkout is read from upgradeConfig.ps1 file)
### ./nowsync uco t 
### 
############################################################

if (($argument -eq "uco" -or $argument -eq "UCO") -and ($Type -eq "t" -or $Type -eq "p" -or $Type -eq "c" -or $Type -eq "r" -or $Type -eq "x" -or $Type -eq "q" -or $Type -eq "m"))
   {
		$flag=0
		$objecttype=Get-NAVObjectidFromtype $Type
		$objecttype=Get-NAVObjectTypeNameFromId $objecttype
		$upgConfigFile="$(split-path $profile)\Config\upgradeConfig.ps1"
		####Checking if file "upgradeConfig.ps1" exits in Config folder
		if (!(Test-Path -Path $upgConfigFile))
			{
				Write-Host "File ${upgConfigFile} which the command uses is not available.Please Check and try again....Press any key to exit.`n" -ForegroundColor Red
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				exit 0				
			}
		else
			{
				Write-Host "The command will perform the checkin of ${objecttype} objects as defined in file ${upgConfigFile} to TFS..... Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
				$choice = Read-Host
				if ($choice -ne "y")
					{
						Write-Host "`nExited...`n" -ForegroundColor Yellow
					}
				else
					{					
						####Sourcing upgrade configuration file from C:\upgradeConfig Folder#####
						. ${upgConfigFile}
						switch ($Type)
						{	     
							"t" {[String]$objectid = $ugTable}
							"p" {[String]$objectid = $ugPage}
							"c" {[String]$objectid = $ugCode}
							"r" {[String]$objectid = $ugReport}
							"x" {[String]$objectid = $ugXMLport}
							"q" {[String]$objectid = $ugQuery}
							"m" {[String]$objectid = $ugMenu}
						}
       			
						if ($objectid -eq "")
							{
								Write-Host "`nNo $objecttype objects defined in file ${upgConfigFile} to checkin....Press any key to exit`n" -ForegroundColor Red
								$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
								exit 0
							}  

						$TFSFolder=Valfromconfig 'TFS Folder Path'
						$objecttype=Get-NAVObjectidFromtype $Type      
						$userfile="$LogFolder\checkoutfile.txt"

						cd $TFSFolder

						$exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive > $userfile"
						cmd /c $exporttfscommand      

						if ($ObjectID.Contains( '|' ))
							{
								$split = $ObjectID.ToString().split("|")
								$count = $split.Count
								$t=0

								While ($t -lt $split.Count)
								{
									$ObjectID=$split[$t]
									Lock-Object -Database $Database -Server $Server -Type $objecttype -ID $ObjectID                    
									$t++
								}
							}
						else
							{
								Lock-Object -Database $Database -Server $Server -Type $objecttype -ID $ObjectID
							}
						Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
						exit 0		
					}
			}
	}

############################################################
##Calling of function basleine to baseline of all objects
### ./nowsync bl all 
############################################################

if ( ($argument -eq "bl" -or $argument -eq "BL") -and ($type -eq "all" -or $type -eq "ALL"))
{
	$flag=0
	NAVApplicationObjectFilelist -NavWorkspace $NavWorkspace -Database $Database -Server $Server -LogFolder $LogFolder

	Write-Host "The command would perform initial baseline of local NAV database objects into TFS.Please make sure that the `"NavWorkSpace`" folder in TFS should be empty.Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
	$choice = Read-Host
	
	if ($choice -ne "y")
		{
			Write-Host "`nExited...`n" -ForegroundColor Yellow
			exit 0
		}	   
	else
		{
			Baselineobjects -LogFolder $LogFolder
		}
}

############################################################
##Calling of function undobranchmerge for revert branch merge
### ./nowsync ls all                 //list all users co objects
### ./nowsync ls local               //list local user co objects
### ./nowsync ls user "username"     // list co object of user provided in parameter
############################################################
if (($argument -eq "ls" -and $Type -eq "all" ) -or ($argument -eq "ls" -and $Type -eq "local" ) -or ($argument -eq "ls" -and $Type -eq "user" ))
  {
   if ( $Type -eq "all")  # all for all worksapce object listing
   {
    co-objectlist "all"
   }
if ( $Type -eq "local")   # local for user local worksapce object listing 
   {
    co-objectlist "local"
    }
if ( $Type -eq "user")   # local for user local worksapce object listing 
   {
    co-objectlist "user" -username $ObjectID
    }
  $flag=0
  }

############################################################
##Calling of function for CI of multiple objects 
### ./nowsync co t "3|6"
### ./nowsync ci t "3|6"
############################################################ 
if (( $argument -eq "ci" -or $argument -eq "CI" ) -and ($Type -eq "t" -or $Type -eq "p" -or $Type -eq "c" -or $Type -eq "r" -or $Type -eq "x" -or $Type -eq "q" -or $Type -eq "m"))
   {
		if ($objectid -eq "")
        {
			Write-Host "Input missing in Command Please Check the command and try again..........Press any key to exit`n" -ForegroundColor Red
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
		
		$flag=0
        $TFSFolder=Valfromconfig 'TFS Folder Path'
		$objTypeID=Get-NAVObjectidFromtype $Type
        $objecttype=Get-NAVObjectTypeNameFromId $objTypeID
        $userfile="$LogFolder\checkoutfile.txt"
        $Multi ="No"
        $split = $ObjectID.ToString().split("|")
        $count = $split.Count
		
		foreach ($objID in $split)
		{
			NavObjectValidation	-Database $Database -Server $Server -Type $objTypeID -ID $ObjID						
		}		
		cd $TFSFolder
		$exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive > $userfile"
		cmd /c $exporttfscommand
		$file = Get-Content $userfile
		$objary=@()
		$objStat="T"
		foreach ($objID in $split)
		{
			$objectname="${objecttype}_${objID}.txt"									
			$exporttfscommand ="tf.exe dir ""$navSrvPath/$objecttype/$objectname"" /server:""$tfsCollection"""
			$cmdOutput=$(cmd /c $exporttfscommand)|select-string "No items match"
			if ($cmdOutput)
				{
					UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "add"
					$objary+=$objID
				}
			elseif ($(get-content $userfile | select-string edit.*$objectname))
				{						
					UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "Yes"
					$objary+=$objID
				}
			else
				{
					Write-Host "Object $objectname is not Checked out in TFS Workspace" -ForegroundColor Red
					$objStat="F"
				}
		}
		
		if ($objStat -eq "F") { Write-Host "`nCheck-in to TFS Stopped due to failures in objects`n" -ForegroundColor Red; exit 0 }
		#Check in single/multiple files(New and checkout files)
		TFSCheckin -Type $objTypeID -ID $objary
		Write-Host "...............Press any key to exit ..." -ForegroundColor Yellow
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0		
	}
                
############################################################
##Calling of function for CO for mutiple/single objects
##Calling of function for CI for single object
## ./nowsync co t 3
## ./nowsync ci t 3
## ./nowsync co t "3|6|9"
###########################################################
if (( $argument -eq "co" -or $argument -eq "CO" ) -and ($Type -eq "t" -or $Type -eq "p" -or $Type -eq "c" -or $Type -eq "r" -or $Type -eq "x" -or $Type -eq "q" -or $Type -eq "m"))
  {
        if ($objectid -eq "")
        {
            Write-Host "Input missing in Command Please Check the command try again..........Press any key to exit`n" -ForegroundColor Red
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
        $flag=0
        $TFSFolder=Valfromconfig 'TFS Folder Path'
        $otype=Get-NAVObjectidFromtype $Type
        $objecttype=Get-NAVObjectTypeNameFromId $otype
        $userfile="$LogFolder\checkoutfile.txt"
        $objectname=$objecttype + '_' + "$ID"  + '.txt'
        $flag=0
        cd $TFSFolder
        $exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive > $userfile"
        cmd /c $exporttfscommand
        $Multi ="No"
        if ( $ObjectID.Contains( '|' ) )
            {
               $split = $ObjectID.ToString().split("|")
               $count = $split.Count
               $t=0
               While ($t -lt $split.Count)
                 {
                    $ObjectID=$split[$t]
                    $objecttype=Get-NAVObjectidFromtype $Type
                    if ( $argument -eq "co" -or $argument -eq "CO" )
                       {
                          Lock-Object -Database $Database -Server $Server -Type $objecttype -ID $ObjectID
                        }
                    $t++
                  }
            }
         else
             {
                $objecttype=Get-NAVObjectidFromtype $Type
                if ( $argument -eq "co" -or $argument -eq "CO" )
                  {
                    Lock-Object -Database $Database -Server $Server -Type $objecttype -ID $ObjectID
                  }
             }
        Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
   }
 
############################################################
##Calling of function for adding new nav objects into TFS
##Calling of function for undo changes (revert) from nav
## ./nowsync add t 3
## ./nowsync undo t 3
###########################################################

 if (($argument -eq "undo" -or $argument -eq "UNDO") -and  ($Type -eq "t" -or $Type -eq "p" -or $Type -eq "c" -or $Type -eq "r" -or $Type -eq "x" -or $Type -eq "q" -or $Type -eq "m"))
	{
		if ($objectid -eq "")
        {
            Write-Host "Input missing in Command Please Check the command try again..........Press any key to exit`n" -ForegroundColor Red
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
		
		$flag=0
        $TFSFolder=Valfromconfig 'TFS Folder Path'
		$objTypeID=Get-NAVObjectidFromtype $Type
		$objecttype=Get-NAVObjectTypeNameFromId $objTypeID
        $userfile="$LogFolder\checkoutfile.txt"
		$split = $ObjectID.ToString().split("|")
		
		foreach ($objID in $split)
		{
			NavObjectValidation	-Database $Database -Server $Server -Type $objTypeID -ID $ObjID						
		}
		
        cd $TFSFolder
        $exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive > $userfile"
        cmd /c $exporttfscommand
		$file = Get-Content $userfile
		
		foreach ($objID in $split)
		{
			$objectname="${objecttype}_${objID}.txt"								
			$exporttfscommand ="tf.exe dir ""$navSrvPath/$objecttype/$objectname"" /server:""$tfsCollection"""
			$cmdOutput=$(cmd /c $exporttfscommand)|select-string "No items match"

			if ($cmdOutput)
				{
					Write-Host "Object $objectname is not available in TFS`n" -ForegroundColor Red
				}
			elseif ($(get-content $userfile | select-string edit.*$objectname))
				{						
					#Performs undo operation for checkout-file.
					$exporttfscommand ="tf.exe undo /noprompt ""$NavWorkspace\$objecttype\$objectname"""
					cmd /c $exporttfscommand
					UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "undo"
				}
			else
				{
					#Performs forceful get latest on non-checkout file
					$exporttfscommand ="tf.exe get /force ""$NavWorkspace\$objecttype\$objectname"""		
					cmd /c $exporttfscommand
					UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "undo"
				}
		}
		
		Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		exit 0		
	}
	
############################################################
##Calling of function to update local nav DB with TFS objects from latest chages from other users
## ./nowsync gl change

##Calling of function to update/sync local nav DB with all TFS objects
## ./nowsync gl all
############################################################
	if ( ($argument -eq "gl" -or $argument -eq "GL") -and ($Type -eq "change" -or $Type -eq "CHANGE" -or $type -eq "all" -or $type -eq "ALL"))
		{
			$flag=0
			Write-Host "The command would sync your database with the TFS objects and the changes in your database will be overrided with the TFS. Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
			$choice = Read-Host
	
			if ($choice -ne "y")
				{
					Write-Host "`nExited...`n" -ForegroundColor Yellow
					exit 0
				}	   
			else
				{
					if ($Type -eq "change" -or $Type -eq "CHANGE")
						{
							getlatestDB -Database $Database -Server $Server
						}
					elseif ($type -eq "all" -or $type -eq "ALL")
							{
							$objectname="Null"
							co-objectlist "local"
							TFS-Getlatest -objectname $objectname
							Compile-NAVApplicationObject -DatabaseServer $Server -DatabaseName $Database -SynchronizeSchemaChanges Yes
							}
					Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
					$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					exit 0
				}
		}  
   
############################################################
##Calling of function to update DB with latest objects as specified in the parameter
## ./nowsync gl t 3
## ./nowsync gl t "3|6|9"
###########################################################
 if ( ($argument -eq "gl" -or $argument -eq "GL") -and ($Type -eq "t" -or $Type -eq "p" -or $Type -eq "c" -or $Type -eq "r" -or $Type -eq "x" -or $Type -eq "q" -or $Type -eq "m"))
  {
	$flag=0
    if ($objectid -eq "")
        {
            Write-Host "Input missing in Command Please Check the command try again..........Press any key to exit`n" -ForegroundColor Red
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
		
	Write-Host "The command would sync your database with the TFS objects and the changes in your database will be overrided with the TFS. Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
	$choice = Read-Host
	
	if ($choice -ne "y")
		{
			Write-Host "`nExited...`n" -ForegroundColor Yellow
			exit 0
		}	 	
   else
		{
			co-objectlist "local" > $null
			Remove-Item "$LogFolder\Log_*.txt" -Force
			if ( $ObjectID.Contains( '|' ) )
				{
					$split = $ObjectID.ToString().split("|")
					$count = $split.Count
					$t=0
					While ($t -lt $split.Count)
					{
						$ObjectID=$split[$t]
						$objecttype=Get-NAVObjectidFromtype $Type
						TFS-Getlatest -Type $objecttype -ID $ObjectID
						$t++
					}
				}     
            else 
				{
					$objecttype=Get-NAVObjectidFromtype $Type
					TFS-Getlatest -Type $objecttype -ID $ObjectID
				}
			Compile-NAVApplicationObject -DatabaseServer $Server -DatabaseName $Database -SynchronizeSchemaChanges Yes
			Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			exit 0
		}  
 }

 #####################MERGE ################################
 
 if ( ($argument -eq "merge" -or $argument -eq "Merge") )
	{
	$flag=0
	$TFSFolder=Valfromconfig 'Powershell Path'
	$autual_path="$TFSFolder\..\..\..\"
	$autal_path
	Write-host "Press Y for only one Changeset Number to Merge "
	$choice= Read-Host
if( $choice -eq 'Y' -or 'y')
{
	Write-host "Enter the Changeset number to Merge"
	$changeset_start= Read-Host
	tf merge /version:C$changeset_start~C$changeset_start  Dev Master /recursive
}
else
{
	Write-host "Enter the Changeset IDs which are contigous Ex: Changeset to Merge from 6000 to 6005"
	Write-host "Enter the Start Changeset number to Merge"
	$changeset_start= Read-Host
	Write-host "Enter the End changeset number to Merge "
	$changeset_end= Read-Host

 tf merge /version:C$changeset_start~C$changeset_end  Dev Master /recursive
}

Write-host "Enter the ShelveSet Name"
$shelve_name= Read-Host
 tf shelve $shelve_name
 tf checkin
	
}

#####################End MERGE ################################

############################################################
############## Perform external file Check-in ############
###########################################################
if (( $argument -eq "eci" -or $argument -eq "ECI" ))
   {
		$flag=0
        $TFSFolder=Valfromconfig 'TFS Folder Path'
		#write-host "2k108"
		Write-host "Press Y/y to continue"
		$choice= Read-Host
		if ($choice -ne "Y" -or $choice -ne "y")
			{
			   exit 0
			}
		else
		{
			tf checkin
		}
			
	}
                
############################################################
############## Perform external file Check-out ############
###########################################################
if (( $argument -eq "eco" -or $argument -eq "ECO" ))
  {
        $flag=0
        $TFSFolder=Valfromconfig 'TFS Folder Path'
        #write-host "2k108"
        Write-host "Enter the filename to checkout "
		$filename= Read-Host
		if ($filename -eq "")
			{
				Write-Host "Input missing in Command Please Check the command try again..........Press any key to exit`n" -ForegroundColor Red
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
			}
		else
		{
		tf checkout $filename
		}
   }
   
############################################################
############## Perform external file add ############
###########################################################
if (( $argument -eq "eadd" -or $argument -eq "EADD" ))
   {
		$flag=0
        $TFSFolder=Valfromconfig 'TFS Folder Path'
		#write-host "2k108"
		Write-host "Enter the filename to Add "
		$filename= Read-Host
		if ($filename -eq "")
			{
				Write-Host "Input missing in Command Please Check the command try again..........Press any key to exit`n" -ForegroundColor Red
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				exit 0
			}
		else
			{
				tf add $filename
			}
			
	}
     
	 ############################################################
############## Perform external file UNDO ############
###########################################################
if (( $argument -eq "eundo" -or $argument -eq "EUNDO" ))
   {
		$flag=0
        $TFSFolder=Valfromconfig 'TFS Folder Path'
		#write-host "2k108"
		Write-host "Enter the filename to UNDO "
		$filename= Read-Host
		if ($filename -eq "")
			{
				Write-Host "Input missing in Command Please Check the command try again..........Press any key to exit`n" -ForegroundColor Red
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
				exit 0
			}
		else
			{
				tf undo $filename
			}
			
	}
	 ############################################################
############## Perform external file Update workspace ############
###########################################################
if (( $argument -eq "eup" -or $argument -eq "EUP" ))
   {
	Write-Host "Updating Workspace" -ForegroundColor green
	tf get .
	}
     
############################################################
##Calling of help function for help list
### ./nowsync help
###########################################################

if ((($argument -eq "help" -or $argument -eq "HELP") -and ($argument -eq "" -or $Type -eq "")) -or ($argument -eq "" -and $Type -eq "" -and $ObjectID -eq ""))
{
abouthelp
exit 0
}    

if (($argument -ne "" -and $Type -eq "help" -and $ObjectID -eq ""))
{
echo $argument "message"
 switch($argument) 
           {
           "co"{
                cohelp
               }
           "ci"{
                cihelp
               }
           "uco"{
                ucohelp
               }
           "uci"{
                ucihelp
               }		
		   "combine"{
			    combcihelp
			   }	   	   
           "ls"{
                lshelp
               }
           "gl"{
                glhelp
               }
			 "up"{
                uphelp
               }
			     
           "undo"{
                undohelp
               }
           "bl"{
                blhelp
               }
			
}
exit 0
}    

############################################################
##Error Shown if wrong command specified in the parameter
###################################### #####################     
if ($flag -eq 1)
   {
    Write-Host "
         ------------------------ Command Not Found -----------------------------
                            Type `"ns help`" more Detail
         ------------------------------------------------------------------------" -ForegroundColor Red
    exit 0
    }