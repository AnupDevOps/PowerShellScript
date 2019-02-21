############ NowSync using GIT Repository 

param(
        [String]$argument,
        [String]$Type,
        [String]$objectid,
		[String]$COID
  )

$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot  

  	write-host "Enter the Env you want to work Dev_Sprint5/Dev_Sprint6"
			$env_new= read-host
	 
		if($env_new -Ceq "Dev_Sprint6")
			{
				Copy-Item -path "$profile\..\Dev_Sprint6\configuration.txt" "$profile\..\Config\configuration.txt" -recurse -Force
				git.exe checkout $env_new
				$path_backup="\\172.16.0.4\Traf\BINARIESBack_DevObjectDev"
				#git pull origin $env_new
			}	
		elseif($env_new -Ceq "Dev_Sprint5" )
			{
				Copy-Item -path "$profile\..\Dev_Sprint5\configuration.txt" "$profile\..\Config\configuration.txt" -recurse -Force
				git.exe checkout $env_new
				$path_backup="\\172.16.0.4\Traf\BINARIESBack_DevObjectUATDev"
				#git pull origin $env_new
			}
		else
			{
				write-host "Request you to type correct Branch name " -ForegroundColor Red
				exit 1
				
			}
			
############################################################
#checking of NAV2015 client path on machine 
############################################################
$TfPath = $(get-content "$profile\..\Config\Configuration.txt"|Select-String 'TFS Folder Path').ToString().split("=")[1]
$env:PATH += ";${TfPath}"

if((Test-Path -Path "C:\Program Files\Microsoft Dynamics NAV\80" ))
{
    Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\80\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -force -DisableNameChecking
	Import-Module "C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -force -DisableNameChecking
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
$poweshellpath=Valfromconfig 'Powershell Path'

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
Write-Host "`nGIT Environment : $Environment" -ForegroundColor Yellow -background Black

############################################################
#Display the Database of Navision 
############################################################
Write-Host "Navision Database : $Database`n" -ForegroundColor Yellow -background Black


############################################################
##Calling of function for CO for mutiple/single objects
##Calling of function for CI for single object
## ./nowsync co t 3
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
		git.exe pull origin $env_new
        $TFSFolder=Valfromconfig 'TFS Folder Path'
		$NavWorkspace=Valfromconfig 'Workspace Path'
        $otype=Get-NAVObjectidFromtype $Type
        $objecttype=Get-NAVObjectTypeNameFromId $otype
        $userfile="$LogFolder\checkoutfile.txt"
        $objectname=$objecttype + '_' + "$objectID" + '.txt'
        $flag=0
		cd $NavWorkspace			
		$exporttfscommand =git.exe status $NavWorkspace > $userfile
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
					$objecttypename=Get-NAVObjectTypeNameFromId $otype
					New-Item "$Path_backup\$objecttypename$ObjectID.txt" -type file
					$env:username > $Path_backup\$objecttypename$ObjectID.txt
					
                    if ( $argument -eq "co" -or $argument -eq "CO" )
                       {
					
										 
					 Lock-Object -Database $Database -Server $Server -Type $objecttype -ID $ObjectID -EnvName $env_new
				     
						  
                        }
                    $t++
                  }
            }
			#########################################################################################################
						#################change start by anup ###################################################################
						#########################################################################################################
						
         else
			
             {
				
                $objecttype=Get-NAVObjectidFromtype $Type
				$spiltObject= $objectname.split("_")
		$objectChecked=$spiltObject[0]
		$objectIDCheck=$spiltObject[1].split(".")
		$finalID=$objectIDCheck[0]
				
					
                if ( $argument -eq "co" -or $argument -eq "CO" )
                  {
					if (Test-Path $Path_backup\$objectChecked$finalID.txt)
						{
						$userChecked = Get-Content "$Path_backup\$objectChecked$finalID.txt"
						write-host "object has been checkout by $userChecked" -ForegroundColor Green
						exit 0
						}
						else 
						{
										 
						Lock-Object -Database $Database -Server $Server -Type $objecttype -ID $ObjectID -EnvName $env_new
							if (Test-Path $NavWorkspace\$objectChecked\$objectname)
										{
											New-Item "$Path_backup\$objectChecked$finalID.txt" -type file
											$env:username > $Path_backup\$objectChecked$finalID.txt
					 
										 }
								else 
											 {
											 write-host "object is Not in GIT" -ForegroundColor Yellow
											 }
												
					 
					 }
						#################################################################################################################
						#########################################################################################################
						#################change END by anup ###################################################################
						#########################################################################################################
						
						  
                  }
             }
        Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
   }

   
############################################################
##Calling of function for CI of multiple objects 
### ./nowsync ci t "3|6"
############################################################ 
if (( $argument -eq "ci" -or $argument -eq "CI" ) -and ($Type -eq "t" -or $Type -eq "p" -or $Type -eq "c" -or $Type -eq "r" -or $Type -eq "x" -or $Type -eq "q" -or $Type -eq "m"))
   {
		#git pull
		if ($objectid -eq "")
        {
			Write-Host "Input missing in Command Please Check the command and try again..........Press any key to exit`n" -ForegroundColor Red
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
		
		$flag=0
        $TFSFolder=Valfromconfig 'TFS Folder Path'
		$NavWorkspace=Valfromconfig 'Workspace Path'
		$navSrvPath=Valfromconfig 'serverWorkSpacePath'
		$objTypeID=Get-NAVObjectidFromtype $Type
        $objecttype=Get-NAVObjectTypeNameFromId $objTypeID
        $userfile="$LogFolder\checkoutfile.txt"
        $Multi ="No"
        $split = $ObjectID.ToString().split("|")
        $count = $split.Count
		$COID=$COID
		getsync -Database $Database -Server $Server -EnvName $env_new
		foreach ($objID in $split)
		{
			NavObjectValidation	-Database $Database -Server $Server -Type $objTypeID -ID $ObjID					
		}		
		
		cd $NavWorkspace
		$exporttfscommand =git.exe status $NavWorkspace > $userfile
		cmd /c $exporttfscommand
		$file = Get-Content $userfile
		$objary=@()
		$objStat="T"
		foreach ($objID in $split)
		{
			$objectname="${objecttype}_${objID}.txt"		
				git cat-file -e origin/${env_new}:$navSrvPath/$objecttype/$objectname
				$cmdOutput="$?"
				#write-host "$objectname "
				# change bu Anup
		$spiltObject= $objectname.split("_")
		$objectChecked=$spiltObject[0]
		$objectIDCheck=$spiltObject[1].split(".")
		$finalID=$objectIDCheck[0]
		##### END ######
				
			if ($cmdOutput -eq "False")
				{
					UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "add" -EnvName $env_new -COID $COID
					$objary+=$objID
					

				}
			elseif ($cmdOutput -eq "True")
				{			
					
					UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "Yes" -EnvName $env_new -COID $COID
					$objary+=$objID
				}
			else
				{
					Write-Host "Object $objectname is not Checked out in GIT Workspace" -ForegroundColor Red
					$objStat="F"
				}
		}
		#Change start here Anup
		
		
	if ($COID)
		{
		foreach ($objID in $split)
		{
		$objectname="${objecttype}_${objID}.txt"		
				
		$spiltObject= $objectname.split("_")
		$objectChecked=$spiltObject[0]
		$objectIDCheck=$spiltObject[1].split(".")
		$finalID=$objectIDCheck[0]

	if((Test-Path -Path "$Path_backup\$objectChecked$finalID.txt" ))
	   {
		$data=get-content "$Path_backup\$objectChecked$finalID.txt"
		if ($data -eq $env:username)
		{
		TFSCheckin -Type $objTypeID -ID $objary -EnvName $env_new -COID $COID
		remove-item  "$Path_backup\$objectChecked$finalID.txt"
		}
		else 
		{
		write-host "Object is Checkedout by another user" -ForegroundColor Yellow
		}
	}
	else
	{
		write-host " Press y if Object is new"
		$newobject=read-host 
		if ( $newobject -Ceq "y")
			{
				TFSCheckin -Type $objTypeID -ID $objary -EnvName $env_new -COID $COID
			}
		else
			{exit 0 }			
	}
} # for closure
	} # if closure
	else{
		
			write-host "Request You to associate the Work Item ID to Checkin" -ForegroundColor Red
			exit 1
		}
		
		if ($objStat -eq "F") { Write-Host "`nCheck-in to GIT Stopped due to failures in objects`n" -ForegroundColor Red; exit 0 }
		#Check in single/multiple files(New and checkout files)
		#TFSCheckin -Type $objTypeID -ID $objary -EnvName $env_new -COID $COID
		
		#remove-item  "\\ttraflon2k922\BINARIES\Back_Dev\Object\$objectChecked$finalID.txt"
		
		Write-Host "...............Press any key to exit ..." -ForegroundColor Yellow
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0		
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
    $shared_folder= "$Path_backup"
								#write-host "enter the user name to check all checkout file"
								$user=$env:username
								$temp=0
								$temp2=0

									if ( test-path "$shared_folder\*.txt" )
									{
										Split-Path -Path "$shared_folder\*.txt" -Leaf -Resolve > $shared_folder\file_checkout.log
									}
									else
									{
									write-host "No file checkout by any user "
									}

								foreach ($filename in 	get-content $shared_folder\file_checkout.log)
								{

									foreach ($name in 	get-content $shared_folder\$filename)
									{
									
									if ($name -eq $user)
										{
											$temp++
											$filename >> $shared_folder\files.log
										}
									else
										{
											$temp2++
										}
									}
								}

								Write-host "Total file checkout by $user is $temp " -ForegroundColor Yellow
								Write-host "Files name are ......" -ForegroundColor Yellow
								get-content "$shared_folder\files.log" 
								Remove-Item $shared_folder\file_checkout.log
								Remove-Item $shared_folder\files.log
    }
if ( $Type -eq "user")   # local for user local worksapce object listing 
   {
   # co-objectlist "user" -username $ObjectID
	$shared_folder= "$Path_backup"
								#write-host "enter the user name to check all checkout file"
								$user=$ObjectID
								$temp=0
								$temp2=0

									if ( test-path "$shared_folder\*.txt" )
									{
										Split-Path -Path "$shared_folder\*.txt" -Leaf -Resolve > $shared_folder\file_checkout.log
									}
									else
									{
									write-host "No file checkout by any user "
									}

								foreach ($filename in 	get-content $shared_folder\file_checkout.log)
								{

									foreach ($name in 	get-content $shared_folder\$filename)
									{
									
									if ($name -eq $user)
										{
											$temp++
											$filename >> $shared_folder\files.log
										}
									else
										{
											$temp2++
										}
									}
								}

								Write-host "Total file checkout by $user is $temp " -ForegroundColor Yellow
								Write-host "Files name are ......" -ForegroundColor Yellow
								get-content "$shared_folder\files.log" 
								Remove-Item $shared_folder\file_checkout.log
								Remove-Item $shared_folder\files.log
    }
  $flag=0
  }
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
				Write-Host "The command will perform the checkin of combined objects as defined in file ${combConfigFile} to GIT..... Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
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
							
							$NavWorkspace=Valfromconfig 'Workspace Path'
							cd $NavWorkspace
							
							$userfile="$LogFolder\checkoutfile.txt"
							$exporttfscommand =git.exe status $NavWorkspace > $userfile
							cmd /c $exporttfscommand
							$file = Get-Content $userfile
							
						
							foreach ($objID in $split)
									{
										$objectname="${objecttype}_${objID}.txt"
										git cat-file -e origin/${env_new}:$navSrvPath/$objecttype/$objectname
										$cmdOutput="$?"
				
									if ($cmdOutput -eq "False")

											{
												UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "add"
												$objary+="${NavWorkspace}\${objecttype}\${objecttype}_${objID}.txt"
											}
										elseif ($cmdOutput -eq "True")
											{						
												UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "Yes"
												$objary+="${NavWorkspace}\${objecttype}\${objecttype}_${objID}.txt"
											}	
										else
											{
												Write-Host "Object $objectname is not Checked out in GIT Workspace" -ForegroundColor Red
												$objStat="F"
											}				
									}
						}
						
						if ($objStat -eq "F") { Write-Host "`nCheck-in to GIT STOPPED due to failures in Objects`n" -ForegroundColor Red; exit 0 }
		  	echo "Enter the WorkItem to Associate"
			$COID= read-host
			git.exe add $objary
			git.exe commit -m "Object Checkin #$COID"
			git.exe push origin ${env_new}
	
		
						Write-Host "...............Press any key to exit ..." -ForegroundColor Yellow
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

	Write-Host "The command would perform initial baseline of local NAV database objects into GIT.Please make sure that the `"NavWorkSpace`" folder in GIT should be empty.Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
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
				Write-Host "The command will perform the checkin of ${objecttype} objects as defined in file ${upgConfigFile} to GIT..... Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
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

						$NavWorkspace=Valfromconfig  'Workspace Path'
						$objecttype=Get-NAVObjectidFromtype $Type      
						$userfile="$LogFolder\checkoutfile.txt"

						cd $NavWorkspace			
						$exporttfscommand =git.exe status $NavWorkspace > $userfile
						cmd /c $exporttfscommand      

						if ($ObjectID.Contains( '|' ))
							{
								$split = $ObjectID.ToString().split("|")
								$count = $split.Count
								$t=0

								While ($t -lt $split.Count)
								{
									$ObjectID=$split[$t]
									Lock-Object -Database $Database -Server $Server -Type $objecttype -ID $ObjectID -EnvName $env_new
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
				Write-Host "The command will perform the checkin of ${objecttype} objects as defined in file ${upgConfigFile} to GIT..... Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
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
						$NavWorkspace=Valfromconfig 'Workspace Path'
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

						cd $NavWorkspace
						$exporttfscommand =git.exe status $NavWorkspace > $userfile
						cmd /c $exporttfscommand		
						$file = Get-Content $userfile
						$objary=@()
						$objStat="T"
						foreach ($objID in $split)
								{
									$objectname="${objecttype}_${objID}.txt"									
									git cat-file -e origin/${env_new}:$navSrvPath/$objecttype/$objectname
									$cmdOutput="$?"
									
									if ($cmdOutput -eq "False")
										{
											UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "add"
											$objary+=$objID
										}
									elseif ($cmdOutput -eq "True")
											{	
												UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "Yes" 
												$objary+=$objID
											}
									else
										{
											Write-Host "Object $objectname is not Checked out in GIT Workspace" -ForegroundColor Red
											$objStat="F"
										}
								}
						if ($objStat -eq "F") { Write-Host "`nCheck-in to GIT STOPPED due to failures in Objects`n" -ForegroundColor Red; exit 0 }
#						Check in single/multiple files(New and checkout files)
						TFSCheckin -Type $objTypeID -ID $objary				
						Write-Host "...............Press any key to exit ..." -ForegroundColor Yellow
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
						exit 0
					}
			}				
	}
############################################################
##Calling of function for adding new nav objects into GIT
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
        $NavWorkspace=Valfromconfig 'Workspace Path'
		$objTypeID=Get-NAVObjectidFromtype $Type
		$objecttype=Get-NAVObjectTypeNameFromId $objTypeID
        $userfile="$LogFolder\checkoutfile.txt"
		$split = $ObjectID.ToString().split("|")
		
		foreach ($objID in $split)
		{
			NavObjectValidation	-Database $Database -Server $Server -Type $objTypeID -ID $ObjID						
		}
		
        cd $NavWorkspace
		$exporttfscommand =git.exe status $NavWorkspace > $userfile
        #$exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive > $userfile"
        cmd /c $exporttfscommand
		$file = Get-Content $userfile
		
		foreach ($objID in $split)
		{
			$objectname="${objecttype}_${objID}.txt"
			# change bu Anup
		$spiltObject= $objectname.split("_")
		$objectChecked=$spiltObject[0]
		$objectIDCheck=$spiltObject[1].split(".")
		$finalID=$objectIDCheck[0]
		##### END ######
			$exporttfscommand=git cat-file -e origin/${env_new}:$navSrvPath/$objecttype/$objectname			
			$cmdOutput=$(cmd /c $exporttfscommand)|select-string "Not a valid object name"

			if ($cmdOutput)
				{
					Write-Host "Object $objectname is not available in GIT`n" -ForegroundColor Red
				}
			elseif ($(get-content $userfile | select-string edit.*$objectname))
				{						
					#Performs undo operation for checkout-file.
					$exporttfscommand =git.exe checkout $NavWorkspace\$objecttype\$objectname
					cmd /c $exporttfscommand
					UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "undo"
				}
			else
				{
					#Performs forceful get latest on non-checkout file
					$exporttfscommand =git.exe checkout $NavWorkspace\$objecttype\$objectname
					cmd /c $exporttfscommand
					UnLock-Object -Database $Database -Server $Server -Type $objTypeID -ID $ObjID -Multi "undo"
				}
				remove-item  "$Path_backup\$objectChecked$finalID.txt"
		}
		
		Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		exit 0		
	}

	
############################################################
##Calling of function to update local nav DB with GIT objects from latest chages from other users
## ./nowsync gl change

##Calling of function to update/sync local nav DB with all GIT objects
## ./nowsync gl all
############################################################
	if ( ($argument -eq "gl" -or $argument -eq "GL") -and ($Type -eq "change" -or $Type -eq "CHANGE" -or $type -eq "all" -or $type -eq "ALL"))
		{
			$flag=0
			Write-Host "The command would sync your database with the GIT objects and the changes in your database will be overrided with the GIT. Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
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
							TFS-Getlatest -objectname $objectname -EnvName $env_new
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
		
	Write-Host "The command would sync your database with the GIT objects and the changes in your database will be overrided with the GIT. Do you want to continue? (Y/N) : " -ForegroundColor Yellow -NoNewline
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
	


############################################################
############## Perform external file Check-in ############
###########################################################
if (( $argument -eq "eci" -or $argument -eq "ECI" ))
   {
		$flag=0
	git pull origin $env_new
        $NavWorkspace=Valfromconfig 'Workspace Path'
		cd $NavWorkspace\..\Automation_input_xml
		Write-host "Enter the filename to Checkin "
		$filename= Read-Host
		Write-host "Enter the WorkItem ID to Associate "
		$COID=Read-Host
			git add $filename
			git.exe commit -m "Object Checkin #$COID"
			git.exe push origin ${env_new} 
		cd $poweshellpath
	}
  
## Working Till Here  

############################################################
############## Perform external file Check-out ############
###########################################################
if (( $argument -eq "eco" -or $argument -eq "ECO" ))
  {
        $flag=0
        $NavWorkspace=Valfromconfig 'Workspace Path'
		cd $NavWorkspace\..\Automation_input_xml
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
			git.exe checkout origin/${env_new} $filename
		}
	cd $poweshellpath
   }
   
   
############################################################
############## Perform external file UNDO ############
###########################################################
if (( $argument -eq "eundo" -or $argument -eq "EUNDO" ))
   {
		$flag=0
        $NavWorkspace=Valfromconfig 'Workspace Path'
		cd $NavWorkspace\..\Automation_input_xml
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
				git.exe checkout $filename
				
			}
	cd $poweshellpath		
	}
	
	##########################################################################################
	if($argument -eq "update")
	{
		$flag=0
		cd C:\GITRepo
				Remove-Item * -force -recurse
				git  clone -q http://172.20.9.123:8080/tfs/Puma/ePumaGlobal/_git/NAV/ .
				git checkout -q $env_new
				
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
	   "update"{
                updatehelp
               }
			
}
exit 0
}  

############################################################
##Error Shown if wrong command specified in the parameter
############################################################     
if ($flag -eq 1)
   {
    Write-Host "
         ------------------------ Command Not Found -----------------------------
                            Type `"ns help`" more Detail
         ------------------------------------------------------------------------" -ForegroundColor Red
    exit 0
    }  