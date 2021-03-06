#############################################################
#
# Description: Common functions used/call in Nowsync 
#
# Author:      Khushwant Singh
# Created:     23/06/2015
# Modified:    28/06/2015 NavObjectimport 
# Modified:    30/07/2015 Added NavObjectcompile in undo option in UnLock-Object function
# Modified:    04/08/2015 Added NavObjectValidation, TFS-Getlatest, UnLock-Object and TFSAdd functions				
#
#############################################################


#############################################################
# Name :       Get-NAVObjectidFromtype
# Description: Convert argument type to object ID
# Variables:   $TypeName     : argument value from console
#                             
# Called by :  Nowsync file for conversion of argument type 
#
#############################################################


Function Get-NAVObjectidFromtype( [String]$TypeName)
{
    switch ($TypeName)
    {
        #"TableData" {$Type = 0}
        "t" {$Type = 1}
        "p" {$Type = 8}
        "c" {$Type = 5}
        "r" {$Type = 3}
        "x" {$Type = 6}
        "q" {$Type = 9}
        "m" {$Type = 7}
    }
    Return $Type
}

#############################################################
# Name :       Get-NAVObjectTypeNameFromId
# Description: Convert object id value to type
# Variables:   $Typeid     : convert id numeric value to string object type value
#                             
# Called by :  Nowsync file for conversion of argument type 
#
#############################################################

Function Get-NAVObjectTypeNameFromId( [int]$TypeId )
{
    switch ($TypeId)
    {
        0 {$Type = "TableData"}
        1 {$Type = "Table"}
        8 {$Type = "Page"}
        5 {$Type = "Codeunit"}
        3 {$Type = "Report"}
        6 {$Type = "XMLPort"}
        9 {$Type = "Query"}
        7 {$Type = "MenuSuite"}
    }
    Return $Type
}

#############################################################
# Name :       Get-NAVObjectTypeIdFromName
# Description: Convert objecttype string value to numeric type
# Variables:   $TypeName     : convert object type to numeric value of object type
#                             
# Called by :  Nowsync file for conversion of argument type 
#
#############################################################

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

#############################################################
# Name :       Valfromconfig
# Description: Reading value from configuration file
# Variables:   $variable     : Variable name to be used to read value from config file
#                             
# Called by :  Nowsync file for reading values from configuration file 
#
#############################################################
function Valfromconfig()
{   
[CmdletBinding()]
    param 
    (
        [String]$variable
        
     )            

$string=Get-Content "$profile\..\Config\Configuration.txt" | Select-String $variable
$split = $string.ToString().split("=")
return $split[1]
}

#############################################################
# Name :       Baselineobjects
# Description: Creates Baseline of NAV objects by reading the objects list file provided by NAVApplicationObjectFilelist function
# Variables:   $LogFolder     : log folder path to read the object list file
#                             
# Called by :  Nowsync file for calling of bl (baseline) function 
#
#############################################################

# function to baseline objects
function Baselineobjects() 
{
 [CmdletBinding()]
 param 
    (
        [String]$LogFolder
    )   
    $logfile1="$LogFolder\Objectslist.txt"
    $logfile="$LogFolder\log.txt"
    $Server=Valfromconfig 'Dev_DBServer'
    $Database=Valfromconfig 'Dev_Database'
    $filedata = Get-Content "$LogFolder\Objectslist.txt"
    Write-Host "Baseline for objects started at $(Get-Date) on $NavWorkspace" -ForegroundColor Yellow
    $NavWorkspace=Valfromconfig 'Workspace Path'
     Add-Content $activitylog "Baseline for objects started at at $(Get-Date) on $NavWorkspace"
    if (!(test-path $logfile1)) 
    {
         Write-Host  "$logfile1 not found." -ForegroundColor Red
         Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
         $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
         exit 0
    }
    $CheckWorkspace = Get-ChildItem $NavWorkspace
    if ($CheckWorkspace.Length -ne 0)
    {
         Write-Host "$NavWorkspace not empty Please Check" -ForegroundColor Red
         Add-Content $activitylog "$NavWorkspace not empty Please Check"
         Write-Host ".........Press any key to exit ..." -ForegroundColor Yellow
         $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
         exit 0
    } 
    foreach ($line in $filedata)
       {
          $split = $line.ToString().split("|")
          $objecttype=Get-NAVObjectTypeNameFromId $split[1]
          $ID=$split[2]
          $NavWorkspace=Valfromconfig 'Workspace Path'
          if(!(Test-Path -Path "$NavWorkspace\$objecttype" ))
             {
               New-Item -ItemType directory -Path $NavWorkspace\$objecttype
               Write-Host "Created Directory $NavWorkspace" -ForegroundColor Green
               $TFSFolder=Valfromconfig 'TFS Folder Path'
               $NavWorkspace=Valfromconfig 'Workspace Path'
               cd $TFSFolder
               $checkincomments="Check in $objecttype into TFS"
               $exporttfscommand ="tf.exe add ""$NavWorkspace/$objecttype"""
               Add-Content $activitylog $exporttfscommand
               cmd /c $exporttfscommand
               cd $poweshellpath
             }     

		  $objectname=$objecttype + '_' + "$ID"  + '.txt'
          $NAVFolder=Valfromconfig 'RTC Client Path'
          $LogFile = "$Logfolder\Log_export_$objectname"
          $ExportFile = "$NavWorkspace\$objecttype\$objectname"

          if (Test-Path "$Logfolder\navcommandresult.txt")
             { 
               Remove-Item "$Logfolder\navcommandresult.txt"
             }
          if (test-path $ExportFile) 
             { 
                remove-item $ExportFile
             }
          $exportfinsqlcommand = """$NAVFolder\finsql.exe"" command=exportobjects,file=$ExportFile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Type=$objecttype;ID=$ID"
          Add-Content $activitylog $exportfinsqlcommand
          cd $NAVFolder
          $Command = $exportfinsqlcommand
          Write-Debug $Command
          cmd /c $Command
          $ExportFileExists = Test-Path "$ExportFile"
          If (-not $ExportFileExists) 
            {
              write-error "Error on exporting to $ExportFile.  Look at the information below."
              if (Test-Path "$Logfolder\navcommandresult.txt")
                {
                   Type "$Logfolder\navcommandresult.txt"
                }
              if (Test-Path $LogFile) 
                {
                   type $LogFile
                 }
            }
            else
            {
               $NavWorkspace = Get-ChildItem $ExportFile
               if ($NavWorkspace.Length -eq 0)
                 {
                   Remove-Item $NavWorkspace
                 } 
                else
                 { }
               if (Test-Path "$Logfolder\navcommandresult.txt")
                {
                    Type "$Logfolder\navcommandresult.txt"
                }
            }
        }
   $TFSFolder=Valfromconfig 'TFS Folder Path'
   $NavWorkspace=Valfromconfig 'Workspace Path'
   cd $TFSFolder
   $checkincomments="Baseline initial objects into TFS"
   $exporttfscommand ="tf.exe add /noprompt /recursive $NavWorkspace"
   cmd /c $exporttfscommand
   $exporttfscommand ="tf.exe checkin $NavWorkspace /recursive /comment:""$checkincomments"""
   Add-Content $activitylog $exportfinsqlcommand
   cmd /c $exporttfscommand
   Add-Content $activitylog "Baseline for objects Completed at $(Get-Date) on $NavWorkspace"
   Write-Host "Baseline for objects Completed at at $(Get-Date) on $NavWorkspace" -ForegroundColor Yellow
   cd $poweshellpath               
} 

#############################################################
# Name :       NAVApplicationObjectFilelist
# Description: This will generate objects text file list which will be used to baseline the objects of NAV into TFS
# Variables:   $NavWorkspace : TFs objets workspace
#              $Database     : Database name
#              $Server       : Server name with instance name
#              $Logfolder    : Log folder path
#               
# Called by :  Nowsync file for baseline object file list functnality
#
#############################################################

function NAVApplicationObjectFilelist
{
    [CmdletBinding()]
    param 
    (
        [String]$NavWorkspace,
        [String]$Database,
        [String]$Server,
        [String]$Logfolder
     )
 $objectfile="$LogFolder\Objectslist.txt"
 $logfile="$LogFolder\log.txt"
 if(!(Test-Path -Path $LogFolder ))
{
    Write-Host "Directory $LogFolder does Not Exists" -ForegroundColor Yellow
    New-Item -ItemType directory -Path $LogFolder
    Write-Host "Created Directory $LogFolder" -ForegroundColor Yellow
}

if(!(Test-Path -Path $NavWorkspace ))
{
    Write-Host "Directory $NavWorkspace does Not Exists" -ForegroundColor Yellow
    New-Item -ItemType directory -Path $NavWorkspace
    Write-Host "Created Directory $NavWorkspace" -ForegroundColor Yellow
}

if (test-path $objectfile) 
{
    remove-item $objectfile
}
# Create and open a database connection
$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
$sqlConnection.Open()
#Create a command object
$sqlCommand = $sqlConnection.CreateCommand()
$sqlCommand.CommandText ="select [Type],[ID],[Version List],[Modified],[Name],[Date],[Time] from Object where ([Modified]=1 or [Modified]=0) and ([Type]!=0)" 
#Execute the Command
$sqlReader = $sqlCommand.ExecuteReader()
#Parse the records
while ($sqlReader.Read())
  { 
    $sqlReader["Name"] + "|" + $sqlReader["Type"] + "|" + $sqlReader["ID"] | Add-Content $objectfile
  } 
# Close the database connection

$sqlConnection.Close() 

}

#############################################################
# Name :       NavObjectExporttxt
# Description: Export Single object from NAV into TFS
# Variables:   $Database : Database name
#              $Server   : Server name with instance name
#              $ID       : object Id value
#              $Type     : object type value
#              
# Called by :  It is called inside UnLock-Object function for ci functionality. 
# Modified : for compile object check before ci objets into TFS 
#
#############################################################

function NavObjectExporttxt() 
{                      
 [CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
        [int]$ID,
        [int]$Type
     )    
        
$NavWorkspace=Valfromconfig 'Workspace Path'
$Logfolder=Valfromconfig 'LogFolder'
$TFSFolder=Valfromconfig 'TFS Folder Path'
$NAVFolder=Valfromconfig 'RTC Client Path'
$objecttype=Get-NAVObjectTypeNameFromId $Type
if(!(Test-Path -Path "$NavWorkspace\$objecttype" ))
 {
    New-Item -ItemType directory -Path $NavWorkspace\$objecttype
    cd $TFSFolder
    $checkincomments="Check in $objecttype into TFS"
    $exporttfscommand ="tf.exe add ""$NavWorkspace/$objecttype"""
    cmd /c $exporttfscommand
    $exporttfscommand ="tf.exe checkin ""$NavWorkspace/$objecttype"" /comment:""$checkincomments"" "
    Add-Content $activitylog $exportfinsqlcommand
    cmd /c $exporttfscommand
    cd $poweshellpath
 }   

$objectname=$objecttype + '_' + "$ID"  + '.txt'
#$LogFile = "$Logfolder\Log_$objectname"  
$ExportFile = "$NavWorkspace\$objecttype\$objectname"
$Compile=1
$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
$sqlConnection.Open()
$sqlCommand = $sqlConnection.CreateCommand()
$sqlCommand.CommandText ="select [Compiled] from Object where [ID]=$ID and Type=$Type"  
$sqlReader = $sqlCommand.ExecuteReader()
while ($sqlReader.Read())
{ 
   if ($sqlReader["Compiled"] -eq 0)
         {
            Write-Host  "Object with [ID]=$ID and Type=$Type is not compiled" -ForegroundColor Yellow
			Write-Host "Do you want to Compile and Checkin ? (Y/N)....No(N) will exit : " -ForegroundColor Yellow -NoNewline
			$choice = Read-Host
            if ($choice -eq "y")
             {	
				$LogFile = "$Logfolder\Log_compile_$objectname"
                Write-Host "Compilation of object with [ID]=$ID and Type=$Type started" -ForegroundColor Yellow
                $exportfinsqlcommand = """$NAVFolder\finsql.exe"" command=compileobjects,file=$ExportFile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Type=$objecttype;ID=$ID"
                Add-Content $activitylog $exportfinsqlcommand
                Write-Debug $exportfinsqlcommand
                cmd /c $exportfinsqlcommand
                if (Test-Path $LogFile)
                {
                $Compile=0      
                Write-Host "Compilation of object with [ID]=$ID and Type=$Type failed.. Please check log for more detail" -ForegroundColor Red
                cd $poweshellpath 
                exit 0
                }
                if (!(Test-Path $LogFile)) 
                {
                $Compile=1           
                Write-Host "Compilation of object with [ID]=$ID and Type=$Type completed sucessfully" -ForegroundColor Green
                }
             }
            else 
             {
                $Compile=0           
                Write-Host "Compilation of object with [ID]=$ID and Type=$Type Cancelled" -ForegroundColor Red
                cd $poweshellpath
                exit 0
             } 
         }
 }
$sqlConnection.Close()   
if ($compile -eq 1)
  {           
    if (Test-Path "$Logfolder\navcommandresult.txt") 
      {
         Remove-Item "$Logfolder\navcommandresult.txt"
      }
    if (test-path $ExportFile) 
      {
         remove-item $ExportFile
      }
	$LogFile = "$Logfolder\Log_export_$objectname"  
    $exportfinsqlcommand = """$NAVFolder\finsql.exe"" command=exportobjects,file=$ExportFile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Type=$objecttype;ID=$ID"
    Add-Content $activitylog $exportfinsqlcommand
    #echo $exportfinsqlcommand
    Write-Debug $exportfinsqlcommand
    cmd /c $exportfinsqlcommand
    $ExportFileExists = Test-Path "$ExportFile"
    If (-not $ExportFileExists) 
       {
        if (Test-Path "$Logfolder\navcommandresult.txt")
             {
               Type "$Logfolder\navcommandresult.txt"
             }
        if (Test-Path $LogFile) 
             {
               Type $LogFile
             }
        }
     else
        {
           $NAVObjectFile = Get-ChildItem $ExportFile
           if ($NAVObjectFile.Length -eq 0)
              {
                Remove-Item $NAVObjectFile
              } 
           if (Test-Path "$Logfolder\navcommandresult.txt")
              {
                Type "$Logfolder\navcommandresult.txt"
              }
       } 
   }
cd $poweshellpath
}


#############################################################
# Name :       NavObjectimport
# Description: Import Single object from TFS into NAV
# Variables:   $Database : Database name
#              $Server   : Server name with instance name
#              $ID       : object Id value
#              $Type     : object type value
#              
# Called by :  It is called inside UnLock-Object, TFSCheckOut, TFS-Getlatest, getlatestDB functions
#
#############################################################

function NavObjectimport() 
{                      
 [CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
        [int]$ID,
        [int]$Type
     )    
        
$NavWorkspace=Valfromconfig 'Workspace Path'    
if(!(Test-Path -Path $NavWorkspace ))
{
    Write-Host "Directory $NavWorkspace does Not Exists" -ForegroundColor Yellow
    New-Item -ItemType directory -Path $NavWorkspace
    Write-Host "Created Directory $NavWorkspace" -ForegroundColor Yellow
}

        $Logfolder=Valfromconfig 'LogFolder'
        $objecttype=Get-NAVObjectTypeNameFromId $Type
        
  if(!(Test-Path -Path "$NavWorkspace\$objecttype" ))
{
    Write-Host "$NavWorkspace\$objecttype Not Exits" -ForegroundColor Yellow
}     
        $NAVFolder=Valfromconfig 'RTC Client Path'
        $objectname=$objecttype + '_' + "$ID"  + '.txt'
        $importFile = "$NavWorkspace\$objecttype\$objectname"
        $LogFile = "$Logfolder\Log_import_$objectname"
        if (Test-Path "$Logfolder\navcommandresult.txt") 
         {
           Remove-Item "$Logfolder\navcommandresult.txt"
         }
        $importfinsqlcommand = """$NAVFolder\finsql.exe"" command=importobjects,file=$importFile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Type=$objecttype;ID=$ID"
        Add-Content $activitylog $importfinsqlcommand
        Write-Debug $importfinsqlcommand
        cmd /c $importfinsqlcommand
        if (Test-Path "$Logfolder\navcommandresult.txt")
        {
                Type "$Logfolder\navcommandresult.txt"
        }
    }   

#############################################################
# Name :       NavObjectcompile
# Description: Compile Single object into NAV
# Variables:   $Database : Database name
#              $Server   : Server name with instance name
#              $ID       : object Id value
#              $Type     : object type value
#              
# Called by :  It is called inside UnLock-Object and TFSCheckOut functions
#
#############################################################
function NavObjectcompile() 
{
 [CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
        [int]$ID,
        [int]$Type
    )    
        
$NavWorkspace=Valfromconfig 'Workspace Path'    
$Logfolder=Valfromconfig 'LogFolder'
$objecttype=Get-NAVObjectTypeNameFromId $Type
$NAVFolder=Valfromconfig 'RTC Client Path'
$objectname=$objecttype + '_' + "$ID"  + '.txt'
$compilefile = "$NavWorkspace\$objecttype\$objectname"
$LogFile = "$Logfolder\Log_compile_$objectname"
if (Test-Path "$Logfolder\navcommandresult.txt") 
  {
   Remove-Item "$Logfolder\navcommandresult.txt"
  }
$compilefinsqlcommand = """$NAVFolder\finsql.exe"" command=compileobjects,file=$compilefile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Type=$objecttype;ID=$ID"
Add-Content $activitylog $compilefinsqlcommand
Write-Debug $compilefinsqlcommand
cmd /c $compilefinsqlcommand
if (Test-Path "$Logfolder\navcommandresult.txt")
  {
    Type "$Logfolder\navcommandresult.txt"
  }
} ## end of function compile   


#############################################################
# Name :       Lock-Object
# Description: Function to lock the object from TFS
# Variables:   $Database : Database name
#              $Server   : Server name with instance name
#              $ID       : object Id value
#              $Type     : object type value
#              
# Called by :  Nowsync file for CO and UCO functionality
#
#############################################################

function Lock-Object
{
    [CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
        [int]$ID,
        [int]$Type 
     )
$LogFolder=Valfromconfig 'LogFolder'
$TFSFolder=Valfromconfig 'TFS Folder Path'
$objecttype=Get-NAVObjectTypeNameFromId $Type
$objectname=$objecttype + '_' + "$ID"  + '.txt'
$userfile="$LogFolder\checkoutfile.txt"
$flag=0
$file = Get-Content $userfile
if ($file -match "edit.*$objectname" )
	{
		Write-Host "Object $objectname Already Checkout in TFS Workspace`n" -ForegroundColor Red
		$flag=1
	}

if ($file -match "add.*$objectname" )
	{
		Write-Host "New Object $objectname added into TFS has checkin pending so can't check-out from TFS`n" -ForegroundColor Red 
		$flag=1
	}   

if ($flag -eq 0)
	{
		TFSCheckOut -Database $Database -Server $server -Type $Type -ID $ID
	}
cd $poweshellpath
}

#############################################################
# Name :       UnLock-Object
# Description: Function to unlock the object from TFS
# Variables:   $Database : Database name
#              $Server   : Server name with instance name
#              $ID       : object Id value
#              $Type     : object type value
#              $Multi    : Case switch value
# Called by :  Nowsync file for CI and UCI functionality
#
#############################################################

function UnLock-Object
{
    [CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
        [int]$ID,
        [int]$Type,
        [String]$Multi       
     )
   
   $LogFolder=Valfromconfig 'LogFolder'
   $NavWorkspace=Valfromconfig 'Workspace Path'
   $objecttype=Get-NAVObjectTypeNameFromId $Type
   $objectname=$objecttype + '_' + "$ID"  + '.txt'
   $flag=1
   
   switch($Multi) 
    {
           "Yes"{
                NavObjectExporttxt -Database $Database -Server $server -ID $ID -Type $Type
				Write-Host "Object with [ID]=$ID and Type=$Type export completed from Navision" -ForegroundColor Green
                }
		   "add"{
                NavObjectExporttxt -Database $Database -Server $server -ID $ID -Type $Type
				Write-Host "Object with [ID]=$ID and Type=$Type export completed from Navision" -ForegroundColor Green	
				TFSAdd -Type $Type -ID $ID
				Write-Host "New Object with [ID]=$ID and Type=$Type Added into TFS" -ForegroundColor Green
                }
          "undo"{
                NavObjectimport -Database $Database -Server $server -Type $Type -ID $ID
                NavObjectcompile -Database $Database -Server $server -Type $Type -ID $ID
				$logFile2Check="${LogFolder}\Log_${objecttype}_${ID}.txt"

				if (Test-Path $logFile2Check)
					{ 
						Write-Host "Object with [ID]=$ID and Type=$objecttype performed undo in TFS but encounted error while importing object into Navision`n" -ForegroundColor Red							   
					}
				else 
					{ 
						Write-Host "Object with [ID]=$ID and Type=$Type reverted to last checkin state`n" -ForegroundColor Green
					}
                }
    }

 cd $poweshellpath 
}  

#############################################################
# Name :       TFSCheckOut
# Description: Function to Checkout the object from TFS
# Variables:   $ID       : object Id value
#              $Type     : object type value
#             
# Called by :  Lock-Object function for CO functionality
# Called in : Valfromconfig for reading values from configuration files
#
#############################################################

function TFSCheckOut
{
[CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
        [int]$Type,
        [int]$ID

    )
	$LogFolder=Valfromconfig 'LogFolder' 
    $TFSFolder=Valfromconfig 'TFS Folder Path'
	$tfsCollection=Valfromconfig 'tfsCollectionURL'
	$navSrvPath=Valfromconfig 'serverWorkSpacePath'
    $NavWorkspace=Valfromconfig 'Workspace Path'
    $objecttype=Get-NAVObjectTypeNameFromId $Type
    $objectname=$objecttype + '_' + "$ID"  + '.txt'
    cd $TFSFolder
	$exporttfscommand ="tf.exe dir ""$navSrvPath/$objecttype/$objectname"" /server:""$tfsCollection"""
	$cmdOutput=$(cmd /c $exporttfscommand)|select-string "No items match"
	if ($cmdOutput)
		{
			Write-Host "Object with [ID]=$ID and Type=$Type Not Found in TFS`n" -ForegroundColor Red
		}
	else
		{
			$exporttfscommand ="tf.exe checkout ""$NavWorkspace\$objecttype\$objectname"""
			Add-Content $activitylog $exporttfscommand
			cmd /c $exporttfscommand
			if ($LASTEXITCODE -eq "0")
				{
					NavObjectimport -Database $Database -Server $server -Type $Type -ID $ID
					NavObjectcompile -Database $Database -Server $server -Type $Type -ID $ID
					$logFile2Check="${LogFolder}\Log_${objecttype}_${ID}.txt"
					if (Test-Path $logFile2Check)
						{	
							Write-Host "Object with [ID]=$ID and Type=$Type is Checked out from TFS but encountered error while importing object to Navision`n" -ForegroundColor Red
						}
					else 
						{ 
							Write-Host "Object with [ID]=$ID and Type=$Type is Checked out from TFS`n" -ForegroundColor Green
						}
				}		
			else 
				{
					Write-Host "Encountered issue while checking out Object with [ID]=$ID and Type=$Type from TFS`n" -ForegroundColor Red
				}									
		}
	cd $poweshellpath	
}				
	 
#############################################################
# Name :       NavObjectValidation
# Description: Checks a Single object NAV database for its validity of presence
# Variables:   $Database : Database name
#              $Server   : Server name with instance name
#              $ID       : object Id value
#              $Type     : object type value
#              
# Called by :  Nowsync file for CI functionality
#
#############################################################
function NavObjectValidation() 
{
[CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
        [int]$Type,
        [int]$ID

     )
	 # Create and open a database connection
	$sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
	$sqlConnection.Open()
	#Create a command object
	$sqlCommand = $sqlConnection.CreateCommand()
	$sqlCommand.CommandText ="select count(*) Result from Object where [Type]=${Type} and [ID]=${ID}"  
	#Execute the Command
	$sqlReader = $sqlCommand.ExecuteReader()
	#Parse the records
	while ($sqlReader.Read())
	{ 
		$validObj=$sqlReader["Result"]
	} 
	# Close the database connection
	$sqlConnection.Close()

	if ($validObj -eq 1) {}
	elseif ($validObj -eq 0)
           {
				Write-Host "Object with [ID]=$ID and Type=$Type Not Found in Navision" -ForegroundColor Red
				exit 0
           }
	else
		   {
				Write-Host "There can't be multiple instances($validObj times) of Object with [ID]=$id and Type=$Type in Navision" -ForegroundColor Red
				exit 0
	       }
		   
}

#############################################################
# Name :       TFSAdd
# Description: Function to add new object into TFS
# Variables:   $ID       : object Id value
#              $Type     : object type value
#             
# Called by : UnLock-Object for CI functionality
# Called in : Valfromconfig for reading values from configuration files
# Modified  : 20/04/2015 for lock dependency removal 
#             21/04/2015 for checkin with add file changes 
#
#############################################################

function TFSAdd
{
[CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server,
        [int]$Type,
        [int]$ID
     )
    $TFSFolder=Valfromconfig 'TFS Folder Path'
    $NavWorkspace=Valfromconfig 'Workspace Path'
    $LogFolder=Valfromconfig 'LogFolder'
    $objecttype=Get-NAVObjectTypeNameFromId $Type
    $objectname=$objecttype + '_' + "$ID"  + '.txt'
    cd $TFSFolder
    $exporttfscommand ="tf.exe add ""$NavWorkspace\$objecttype\$objectname"""
    Add-Content $activitylog $exporttfscommand
    cmd /c $exporttfscommand > $null
	cd $poweshellpath
}

#############################################################
# Name :       TFSCheckin
# Description: Function to checkin singe\multiple files which is\are new or existing object into TFS
# Variables:   $Type     : object type value
#              $ID       : object Id value
#
# Called by : Nowsync
# Called in : Called NowSync main script while ns ci <objecttype> <ID1|ID2|ID3|.....> call
# Modified  : N/A 
#
#############################################################   
  
function TFSCheckin
{
[CmdletBinding()]
    param 
    (
        [String]$objectname,
        [int]$Type,
        [array]$ID
     )
     $TFSFolder=Valfromconfig 'TFS Folder Path'
     $NavWorkspace=Valfromconfig 'Workspace Path'
     $objecttype=Get-NAVObjectTypeNameFromId $Type
     $objIDArray=@()
     $t=0

	 While ($t -lt $ID.Count)
     {
        $ObjectID=$ID[$t]
        $objectname=$objecttype + '_' + "$ObjectID"  + '.txt'
        $filelist="$NavWorkspace\$objecttype\$objectname"
        $objIDArray+=$filelist
        $t++
     }
	 
     $checkincomments="Check in pending changes from PowerShell"
     cd $TFSFolder
	 $exporttfscommand ="tf.exe checkin $objIDArray /comment:""$checkincomments"""
     Add-Content $activitylog $exporttfscommand
     #echo $exporttfscommand
     cmd /c $exporttfscommand
     if($LASTEXITCODE -eq "100")
          {
            cd $poweshellpath
            Write-Host "Checkin of object cancelled by user in TFS" -ForegroundColor Red
            exit 0
          }
     cd $poweshellpath
}

#############################################################
# Name :       TFS-Getlatest
# Description: Function to getlatest object from TFS
# Variables:   $ID       : object Id value
#              $Type     : object type value
#             
# Called by : Nowsync
# Called in : Valfromconfig for reading values from configuration files
# Modified  : N/A 
#
#############################################################

function TFS-Getlatest
{
[CmdletBinding()]
    param 
    (
        [String]$objectname,
        [String]$Type,
        [String]$ID
    )
    
    $TFSFolder=Valfromconfig 'TFS Folder Path'
    $NavWorkspace=Valfromconfig 'Workspace Path'
    $Server=Valfromconfig 'Dev_DBServer'
    $Database=Valfromconfig 'Dev_Database'
    $TFSFolder=Valfromconfig 'TFS Folder Path'
    $NavWorkspace=Valfromconfig 'Workspace Path'
    $LogFolder=Valfromconfig 'LogFolder'
    $NAVFolder=Valfromconfig 'RTC Client Path'

    cd $TFSFolder
    if ($objectname -eq "Null" )
    {
		Remove-Item "$LogFolder\Log_*.txt" -Force
        $exporttfscommand ="tf.exe get ""$NavWorkspace"" > ""$LogFolder\NavWorkspace.txt"" "
        Add-Content $activitylog $exporttfscommand
        #echo $exporttfscommand
        cmd /c $exporttfscommand
        $directories=Get-ChildItem -Path $NavWorkspace
        foreach ($directory in $directories) 
        {
           $Objecttype = $directory.Name
           #echo "Object type is $Objecttype"
           $exporttfscommand ="tf.exe get ""$NavWorkspace\$Objecttype"" > ""$LogFolder\$Objecttype.txt"" "
           Add-Content $activitylog $exporttfscommand
           #echo $exporttfscommand
           cmd /c $exporttfscommand
           $files=Get-ChildItem -Path "$NavWorkspace\$Objecttype"
           Write-Host "Update Started for $Objecttype... All Objets are getting Refreshed with latest TFS Code. ...Will take long time"  -ForegroundColor Yellow
           foreach ($file in $files) 
             {
                $split=$file.Name
                $Sel = Select-String  -path "$LogFolder\localuserlist.txt" -pattern $split 
                If ($Sel -ne $null)
                  {
                   Write-Host "Object $split Already Checkout in TFS Workspace.Please Check in the Object" -ForegroundColor Yellow
                   #exit 0
                  }
                else
                  {
                    $importFile = "$NavWorkspace\$objecttype\$file"
                    $LogFile="$LogFolder\Log_import_$file"
                    $split=$split.Split("_")
                    $split=$split[1].Split(".")
                    $id=$split[0]
                    $exportfinsqlcommand = """$NAVFolder\finsql.exe"" command=importobjects,file=$importFile,servername=$Server,database=$Database,Logfile=$LogFile,filter=Type=$objecttype;ID=$ID"
                    Add-Content $activitylog $exportfinsqlcommand
                    #echo $exportfinsqlcommand
                    cmd /c $exportfinsqlcommand
                  }
                
             }
         }
     }
     else 
     {
        $objecttype=Get-NAVObjectTypeNameFromId $Type
        $objectname=$objecttype + '_' + "$ID"  + '.txt'
        $Sel = Select-String  -path "$LogFolder\localuserlist.txt" -pattern $objectname 
        If ($Sel -ne $null)
           {
             write-host "Object $objectname Already Checkout in TFS Workspace.Please Check in the Object" -ForegroundColor Red
             exit 0
           } 
        else
           {
             $exporttfscommand ="tf.exe get ""$NavWorkspace\$objecttype\$objectname""" 
             Add-Content $activitylog $exporttfscommand
             #echo $exporttfscommand
             cmd /c $exporttfscommand
             NavObjectimport -Database $Database -Server $server -Type $Type -ID $ID
			 $logFile2Check="${LogFolder}\Log_import_${objecttype}_${ID}.txt"
			 if (Test-Path $logFile2Check)
				{ 
					Write-Host "Database update with latest Object of type=$objecttype with id=$ID failed`n" -ForegroundColor Red
				}
			 else 
				{ 
					Write-Host "Database update with latest Object of type=$objecttype with id=$ID successful`n" -ForegroundColor Green
				}
           }
     }
   cd $poweshellpath
 } 


#############################################################
# Name :       co-objectlist
# Description: Function to list check out object from TFS
# Variables:   $case     : object Id value
#              $username : username value listing
#             
# Called by : Nowsync for list functionality
# Called in : Valfromconfig for reading values from configuration files
#
###############################################################
function co-objectlist
{
[CmdletBinding()]
    param 
    (
        [String]$case,
        [String]$username
     )
$NavWorkspace=Valfromconfig 'Workspace Path'
$TFSFolder=Valfromconfig 'TFS Folder Path'
$LogFolder=Valfromconfig 'LogFolder'
Remove-Item "$LogFolder\*list.txt" -Force
cd $TFSFolder
switch($case) 
           {
           "local"{
                $exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive "
                Add-Content $activitylog $exporttfscommand
                cmd /c $exporttfscommand 
                cmd /c $exporttfscommand | Out-File "$LogFolder\localuserlist.txt"
                }
          "all"{
                $exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive /user:* "
                Add-Content $activitylog $exporttfscommand
                cmd /c $exporttfscommand 
                cmd /c $exporttfscommand | Out-File "$LogFolder\alluserlist.txt"
                } 
          "user"{
                $exporttfscommand ="tf.exe status ""$NavWorkspace"" /recursive /user:""$username"" "
                Add-Content $activitylog $exporttfscommand
                cmd /c $exporttfscommand
                cmd /c $exporttfscommand | Out-File "$LogFolder\userwiselist.txt"
                }
          }
cd $poweshellpath
}

##############################################################
# Name :       getlatestDB
# Description: Function to list check out object from TFS
# Variables:   $case     : object Id value
#              $username : username value listing
#             
# Called by : Nowsync to update local NAV DB with latest with TFS objects changes from other users
# Called in : Valfromconfig for reading values from configuration files
#
###############################################################
function getlatestDB
{
[CmdletBinding()]
    param 
    (
        [String]$Database,
        [String]$Server
     )
$TFSFolder=Valfromconfig 'TFS Folder Path'
$NavWorkspace=Valfromconfig 'Workspace Path'
$LogFolder=Valfromconfig 'LogFolder'
$NAVFolder=Valfromconfig 'RTC Client Path'
cd $TFSFolder

$exporttfscommand ="tf.exe get ""$NavWorkspace"" > ""$LogFolder\NavWorkspace.txt"" "
cmd /c $exporttfscommand
$exporttfscommand ="tf.exe get ""$NavWorkspace\Table"" > ""$LogFolder\Table.txt"" "
cmd /c $exporttfscommand
$exporttfscommand ="tf.exe get ""$NavWorkspace\Page"" > ""$LogFolder\Page.txt"" "
cmd /c $exporttfscommand
$exporttfscommand ="tf.exe get ""$NavWorkspace\Report"" > ""$LogFolder\Report.txt"" "
cmd /c $exporttfscommand
$exporttfscommand ="tf.exe get ""$NavWorkspace\Codeunit"" > ""$LogFolder\Codeunit.txt"" "
cmd /c $exporttfscommand
$exporttfscommand ="tf.exe get ""$NavWorkspace\Query"" > ""$LogFolder\Query.txt"" "
cmd /c $exporttfscommand
$exporttfscommand ="tf.exe get ""$NavWorkspace\XMLPort"" > ""$LogFolder\XMLPort.txt"" "
cmd /c $exporttfscommand
$exporttfscommand ="tf.exe get ""$NavWorkspace\MenuSuite"" > ""$LogFolder\MenuSuite.txt"" "
cmd /c $exporttfscommand

get-content "$LogFolder\Table.txt" | select -Skip 1 | Out-File "$LogFolder\Table-temp.txt"
(Get-Content "$LogFolder\Table-temp.txt" ) | Foreach-Object { $_.split()[1..2] -join ' ' } | Out-File  "$LogFolder\Table.txt"
get-content "$LogFolder\Page.txt" | select -Skip 1 | Out-File "$LogFolder\Page-temp.txt"
(Get-Content "$LogFolder\Page-temp.txt" ) | Foreach-Object { $_.split()[1..2] -join ' ' } | Out-File  "$LogFolder\Page.txt"
get-content "$LogFolder\Report.txt" | select -Skip 1 | Out-File "$LogFolder\Report-temp.txt"
(Get-Content "$LogFolder\Report-temp.txt" ) | Foreach-Object { $_.split()[1..2] -join ' ' } | Out-File  "$LogFolder\Report.txt"
get-content "$LogFolder\Codeunit.txt" | select -Skip 1 | Out-File "$LogFolder\Codeunit-temp.txt"
(Get-Content "$LogFolder\Codeunit-temp.txt" ) | Foreach-Object { $_.split()[1..2] -join ' ' } | Out-File  "$LogFolder\Codeunit.txt"
get-content "$LogFolder\Query.txt" | select -Skip 1 | Out-File "$LogFolder\Query-temp.txt"
(Get-Content "$LogFolder\Query-temp.txt" ) | Foreach-Object { $_.split()[1..2] -join ' ' } | Out-File  "$LogFolder\Query.txt"
get-content "$LogFolder\XMLPort.txt" | select -Skip 1 | Out-File "$LogFolder\XMLPort-temp.txt"
(Get-Content "$LogFolder\XMLPort-temp.txt" ) | Foreach-Object { $_.split()[1..2] -join ' ' } | Out-File  "$LogFolder\XMLPort.txt"
get-content "$LogFolder\MenuSuite.txt" | select -Skip 1 | Out-File "$LogFolder\MenuSuite-temp.txt"
(Get-Content "$LogFolder\MenuSuite-temp.txt" ) | Foreach-Object { $_.split()[1..2] -join ' ' } | Out-File  "$LogFolder\MenuSuite.txt"

Remove-Item "$LogFolder\*temp.txt" -Force
$filedata = Get-Content "$LogFolder\Table.txt"
Write-Host "updating Table objects" -ForegroundColor Yellow
foreach ($line in $filedata)
      {
          $split=$line.Split("_")
          $Type=Get-NAVObjectTypeIdFromName($split[0])
          $split=$split[1].Split(".")
          $id=$split[0]
          NavObjectimport -Database $Database -Server $Server -Type $Type -id $split[0]
       }
$filedata = Get-Content "$LogFolder\Page.txt"
Write-Host "Updating Page objects" -ForegroundColor Yellow
foreach ($line in $filedata)
      {
          $split=$line.Split("_")
          $Type=Get-NAVObjectTypeIdFromName($split[0])
          $split=$split[1].Split(".")
          $id=$split[0]
          NavObjectimport -Database $Database -Server $Server -Type $Type -id $split[0]
       }
$filedata = Get-Content "$LogFolder\Report.txt"
Write-Host "Updating Report objects" -ForegroundColor Yellow
foreach ($line in $filedata)
      {
          $split=$line.Split("_")
          $Type=Get-NAVObjectTypeIdFromName($split[0])
          $split=$split[1].Split(".")
          $id=$split[0]
          NavObjectimport -Database $Database -Server $Server -Type $Type -id $split[0]
       }
$filedata = Get-Content "$LogFolder\Codeunit.txt"
Write-Host "Updating Codeunit objects" -ForegroundColor Yellow
foreach ($line in $filedata)
      {
          $split=$line.Split("_")
          $Type=Get-NAVObjectTypeIdFromName($split[0])
          $split=$split[1].Split(".")
          $id=$split[0]
          NavObjectimport -Database $Database -Server $Server -Type $Type -id $split[0]
       }
$filedata = Get-Content "$LogFolder\Query.txt"
Write-Host "Updating Query objects" -ForegroundColor Yellow
foreach ($line in $filedata)
      {
          $split=$line.Split("_")
          $Type=Get-NAVObjectTypeIdFromName($split[0])
          $split=$split[1].Split(".")
          $id=$split[0]
          NavObjectimport -Database $Database -Server $Server -Type $Type -id $split[0]
       }
$filedata = Get-Content "$LogFolder\XMLPort.txt"
Write-Host "Updating XMLPort objects" -ForegroundColor Yellow
foreach ($line in $filedata)
      {
          $split=$line.Split("_")
          $Type=Get-NAVObjectTypeIdFromName($split[0])
          $split=$split[1].Split(".")
          $id=$split[0]
          NavObjectimport -Database $Database -Server $Server -Type $Type -id $split[0]
       }
$filedata = Get-Content "$LogFolder\MenuSuite.txt"
Write-Host "Updating MenuSuite objects" -ForegroundColor Yellow
foreach ($line in $filedata)
      {
          $split=$line.Split("_")
          $Type=Get-NAVObjectTypeIdFromName($split[0])
          $split=$split[1].Split(".")
          $id=$split[0]
          NavObjectimport -Database $Database -Server $Server -Type $Type -id $split[0]
       }
cd $poweshellpath
Write-Host "Compiling all uncompiled objects objects" -ForegroundColor Yellow
Compile-NAVApplicationObject -DatabaseServer $Server -DatabaseName $Database -SynchronizeSchemaChanges Yes
Write-Host "Update completed sucessfully" -ForegroundColor Yellow
}

Export-ModuleMember -Function getlatestDB
Export-ModuleMember -Function co-objectlist
Export-ModuleMember -Function Lock-Object
Export-ModuleMember -Function UnLock-Object
Export-ModuleMember -Function Valfromconfig
Export-ModuleMember -Function TFS-Getlatest
Export-ModuleMember -Function Get-NAVObjectidFromtype
Export-ModuleMember -Function Baselineobjects
Export-ModuleMember -Function NAVApplicationObjectFilelist
Export-ModuleMember -Function NavObjectValidation
Export-ModuleMember -Function TFSAdd
Export-ModuleMember -Function TFSCheckin
Export-ModuleMember -Function NavObjectimport
Export-ModuleMember -Function NavObjectExporttxt
Export-ModuleMember -Function Get-NAVObjectTypeNameFromId
Export-ModuleMember -Function Get-NAVObjectTypeIdFromName
$poweshellpath=Valfromconfig 'Powershell Path'
$Logfolder=Valfromconfig 'LogFolder'
$activitylog="$Logfolder\activitylogs.txt"