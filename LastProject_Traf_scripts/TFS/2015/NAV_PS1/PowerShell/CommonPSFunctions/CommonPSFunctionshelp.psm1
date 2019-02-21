#############################################################
#
# Description: Common functions used/called in Nowsync 
#
# Author      :   Khushwant Singh
#
#############################################################

#############################################################
# Name        :abouthelp
# Description : Will list help details for Nowsync
# Variables:   
# Called by :  Nowsync file for help functionality
#
#############################################################
Function abouthelp
{
Write-Host "
TOPIC
      NowSync now supports GIT !!
	  Windows Nowsync Help System

SHORT DESCRIPTION
    
      Displays help about Windows Nowsync command and concepts.

For help on NowSync Utility, type:

      ns <command-term> help n" -ForegroundColor Yellow
Write-Host "
EXAMPLES:
      ns help         : Display how to use help on Screen.
                             Use : ns help for more details

      ns ls help      : Display help to list checkout objects on Screen.
                             Use : ns ls help for more details

      ns co help      : Display help for co (Checkout) command on Screen.
                             Use : ns co help for more details

      ns ci help      : Display help for ci (Checkin) command on Screen.
                             Use : ns ci help for more details
						  
      ns uco help     : Display help for uco (Upgrade Checkout) objects command on Screen.
                             Use : ns uco help for more details

      ns uci help     : Display help for uci (Upgrade Checkin) objects command on Screen.
                             Use : ns uci help for more details
	
      ns combine help : Display help for combine (Combine Checkin) objects command on Screen.
                             Use : ns combine help for more details	  						  
						  
      ns gl help      : Display help for gl (getlatest) objects command on Screen.
                             Use : ns gl help for more details

      ns undo help    : Display help for undo objects changes (Revert) command on Screen.
                             Use : ns undo help for more details
						  
      ns bl help      : Display help for bl (Baseline) objects command on Screen.
                          Use : ns bl help for more details
	  
	 ns eci help      :  Display help to Check-In external file objects other than Navision objects.
                          Use : Its is used to check-in other than Navision objects.
									SYNTAX : [ns eci <filename>]
						  				  
	 ns eco help      :  Display help to Check-Out external file objects other than Navision objects.
                          Use : Its is used to check-out files other than Navision objects.
									SYNTAX : [ns eco <filename>]
									
	 ns eadd help     : Display help to Add external file objects other than Navision objects.
                          Use : Its is used to add other than Navision objects.
									SYNTAX : [ns eadd <filename>]
	 ns eup help     : Display help to Update external file objects other than Navision objects.
                          Use : Its is used to Update other than Navision objects.
									SYNTAX : [ns eup]									
	 ns eundo help     : Display help to Undo external file objects other than Navision objects.
                          Use : Its is used to Undo other than Navision objects.
									SYNTAX : [ns eundo <filename>]`n`n" -ForegroundColor Green
}

#############################################################
# Name        : cohelp
# Description : Will list co help details for Nowsync
# Variables:   
# Called by   : Nowsync file for help functionality
#############################################################

Function cohelp
{
Write-Host "
NAME
      Nowsync checkout

SYNOPSIS
    
      Performs Check-out operation of Navision objects/files from GIT Repository
      
SYNTAX     
        
      ns co [ObjectType] [[ObjectNumber] `"[ObjectNumber|ObjectNumber]`"]

      -	[ObjectType]   : object type i.e (t)(table), (p)(Page), (r)(Report), (c)(CodeUnit), (q)(Query), (x)(XMLPort), (m)(MenuScript)
      
      -	[ObjectNumber] : object number

      -`"[ObjectNumber|ObjectNumber]`" : Multiple object can be provided in quotes (`"`") separated by using pipe(|)`n" -ForegroundColor Yellow
Write-Host "
      Example: ns co t 3
               Object of type=table with ID=3 will checkout of GIT with latest version.It will also update NAV DB with latest update.

      Example: ns co t `"3|10|1`"
               Object of type=table with ID's=3,10,1 will checkout of GIT with latest version.It will also update NAV DB with latest update.`n`n" -ForegroundColor Green
}

#############################################################
# Name        : cihelp
# Description : Will list ci help details for Nowsync
# Variables:   
# Called by   : Nowsync file for help functionality
#############################################################

Function cihelp
{
Write-Host "
NAME
      Nowsync check-in object

SYNOPSIS
    
      Performs Check-in operation of Navision objects/files into GIT Repository
      
SYNTAX     
        
       ns ci [ObjectType] [[ObjectNumber]`"[ObjectNumber|ObjectNumber]`"]
     
       - [ObjectType]   : object type i.e (t)(table), (p)(Page), (r)(Report), (c)(CodeUnit), (q)(Query), (x)(XMLPort), (m)(MenuScript)
      
       - [ObjectNumber] : object numbers

       - `"[ObjectNumber|ObjectNumber]`" : Multiple object can be provided in quotes (`"`") separated by using pipe(|)`n" -ForegroundColor Yellow
      
Write-Host "    
      Example: ns ci t 3 <WORKITEM ID>
               Object of type=table with ID=3 will get ready to be checked-in into GIT with latest changes.
               

      Example: ns ci t `"3|10|1`" 
               Object of type=table with ID's=3,10,1 will get ready to be checked-in into GIT with latest changes.
               A Check-in window will pop-up with preselected objects to check-in. Assoicate them with GIT work-Item and perform checkin.

      Note:   Only Compiled objects will be checked in into GIT.
              Nowsync will ask to compile uncompiled objects during checkin command.Cancel will terminate the command 
              Work item Association is compulsory during checkin`n`n" -ForegroundColor Green
}

#############################################################
# Name        : ucohelp
# Description : Will list uco help details for Nowsync
# Variables:   
# Called by   : Nowsync file for help functionality
#############################################################

Function ucohelp
{
Write-Host "
NAME
      Nowsync upgrade checkout

SYNOPSIS
    
      Performs Check-out operation of Navision objects/files from GIT Server based on the object ids mentioned in upgradeConfig.ps1 file for a particular object type
      
SYNTAX     
        
      ns uco [ObjectType]

      -	[ObjectType]   : object type i.e (t)(table), (p)(Page), (r)(Report), (c)(CodeUnit), (q)(Query), (x)(XMLPort), (m)(MenuScript)`n" -ForegroundColor Yellow      

Write-Host "
      Example: ns uco t
               Object of type=table with IDs as mentioned in upgradeConfig.ps1 file will checkout of GIT with latest version.It will also update NAV DB with latest update.`n`n" -ForegroundColor Green
}

#############################################################
# Name        : ucihelp
# Description : Will list ci help details for Nowsync
# Variables:   
# Called by   : Nowsync file for help functionality
#############################################################

Function ucihelp
{
Write-Host "
NAME
      Nowsync upgrade check-in object

SYNOPSIS
    
      Performs Check-in operation of Navision objects/files into GIT based on the object ids mentioned in upgradeConfig.ps1 file for a particular object type
      
SYNTAX     
        
       ns uci [ObjectType]
     
       - [ObjectType]   : object type i.e (t)(table), (p)(Page), (r)(Report), (c)(CodeUnit), (q)(Query), (x)(XMLPort), (m)(MenuScript)`n" -ForegroundColor Yellow
      
Write-Host "
      Example: ns uci t
               Object of type=table with IDs as mentioned in upgradeConfig.ps1 file will get ready to be checked-in into GIT with latest changes.
              A Check-in window will pop-up with preselected objects to check-in. Assoicate them with GIT work-Item and perform checkin.

      Note:   Only Compiled objects will be checked in into GIT.
              Nowsync will ask to compile uncompiled objects during checkin command.Cancel will terminate the command 
              Work item Association is compulsory during checkin`n`n" -ForegroundColor Green
}

#############################################################
# Name        : combcihelp
# Description : Will list ci help details for Nowsync
# Variables:   
# Called by   : Nowsync file for help functionality
#############################################################

Function combcihelp
{
Write-Host "
NAME
      Nowsync combine check-in object

SYNOPSIS
    
      Performs Check-in operation of Navision objects/files into GIT based on the defined object ids and object types as mentioned in combineConfig.ps1 file 
      
SYNTAX     
        
       ns ci combine`n" -ForegroundColor Yellow
      
Write-Host "
      Example: ns ci combine
               Object of various types as defined in `$objSequence variable and defined object IDs in combineConfig.ps1 file will get ready to be checked-in into GIT with latest changes.
               A Check-in window will pop-up with preselected objects to check-in. Assoicate them with GIT work-Item and perform checkin.

      Note:   Only Compiled objects will be checked in into GIT.
              Nowsync will ask to compile uncompiled objects during checkin command.Cancel will terminate the command 
              Work item Association is compulsory during checkin`n`n" -ForegroundColor Green
}

#############################################################
# Name        : lshelp
# Description : Will list ls help details for Nowsync
# Variables:   
# Called by   : Nowsync file for help functionality
#############################################################
Function lshelp
{
Write-Host "
NAME
      Nowsync list check-out/locked objects

SYNOPSIS
    
      Performs list operation of Navision checkout objects/files from GIT on Screen
      
SYNTAX     
        
      ns [ls] [[all] [local] [User]]
      
      -	[all]   : Displays all files check-out\locked by all users in workspace
      
      - [local] : Displays all files checkout\locked by local user in workspace

      - [user]  : Displays files checkout\locked on username filter provided in user parameter workspace`n" -ForegroundColor Yellow 

Write-Host "	  
      Example: ns ls all          
               This will list all Checkout files by all users

      Example: ns ls local
               This will list all Checkout files for local logged in user 

      Example: ns ls user xyz
	  This will list all Checkout files by user `"xyz`" as specified in parameter user`n`n" -ForegroundColor Green 
}

#############################################################
# Name        : glhelp
# Description : Will list gl help details for Nowsync
# Variables:   
# Called by   : Nowsync file for help functionality
#############################################################

Function glhelp
{
Write-Host "
NAME
      Nowsync get latest objects 

SYNOPSIS
    
      Performs get-latest(import) operation of Navision objects/files from GIT into Navision.
      Please be cautions while using these commands it will make chages in your code.
      
SYNTAX     
        
      ns gl [ObjectType] [[ObjectNumber] `"[ObjectNumber|ObjectNumber]`" [change] [all]]
    
      - [ObjectType]   : object type i.e (t)(table), (p)(Page), (r)(Report), (c)(CodeUnit), (q)(Query), (x)(XMLPort), (m)(MenuScript)
      
      - [ObjectNumber] : object numbers

      - `"[ObjectNumber|ObjectNumber]`" : Multiple object can be provided in quotes (`"`") separated by using pipe(|)`n" -ForegroundColor Yellow 

Write-Host "	  
      Example: ns gl t 3
               This will get-latest object of type=table with ID=3 from GIT and sync Navision with latest code.
      
      
      Example: ns gl t 10|1
               This will get-latest objects of type=table with ID=3,10,1 from GIT and sync Navision with latest code.

      
      Example: ns gl change
               using change with gl will sync Nav db with all latest changes from other users.
     
      Example: ns gl all
               using all will sync Nav db with all latest objects present in GIT.`n`n" -ForegroundColor Green
}

#############################################################
# Name        : undohelp
# Description : Will list undo help details for Nowsync
# Variables:   
# Called by   : Nowsync file for help functionality 
#############################################################

Function undohelp
{
Write-Host "
NAME
      Nowsync undo

SYNOPSIS
    
     Performs undo(revert) operation of Navision objects.  

SYNTAX     
        
      ns undo  [ObjectType] [[ObjectNumber] [ObjectNumber|ObjectNumber]

       - [ObjectType]  : object type i.e (t)(table), (p)(Page), (r)(Report), (c)(CodeUnit), (q)(Query), (x)(XMLPort), (m)(MenuScript)
      
      - [ObjectNumber] : object numbers

      - `[ObjectNumber|ObjectNumber]` : Multiple object can be provided in quotes (`"`") separated by using pipe(|)`n" -ForegroundColor Yellow

Write-Host "	  
      Example: ns undo t 3
               This will get-latest object of type=table with ID=3 from GIT and revert the object to last GIT checkin state.
      
      
      Example: ns undo t `"3|10|1`"
               This will get-latest object of type=table with ID=3,10,1 from GIT and revert the objects to last GIT checkin state.`n`n" -ForegroundColor Green
}

#############################################################
# Name        : blhelp
# Description : Will list bl help details for Nowsync
# Created     : 28/04/2015
# Variables:   
# Called by   : Nowsync file for help functionality
#############################################################

Function blhelp
{
Write-Host "
NAME
      Nowsync baseline 

SYNOPSIS
    
      Performs initial baseline of Navision objects into GIT Repository.
      Workspace needs to be blank before you run this command.
      
SYNTAX     
        
      ns [bl] [all]

      -	all: all object type i.e (table),(Page),(Report),(CodeUnit),(Query),(XMLPort),(MenuScript)`n" -ForegroundColor Yellow

Write-Host "	  
      Example: ns bl all
               It will start initial baseine for all objects from Navision into GIT.
               All licensed objects from database will be exported,added and checked-in into GIT.`n`n" -ForegroundColor Green
}



Function ecohelp
{
Write-Host "
NAME
      Nowsync External Check-out 

SYNOPSIS
    
      Performs initial baseline of Navision objects into GIT Repository.
      Workspace needs to be blank before you run this command.
      
SYNTAX     
        
      ns [eco]"

     

Write-Host "	  
      Example: ns eco
	  Before modifying any external object the developer is required to Check Out the object first to get the latest from GIT Repository."
	 
}

Function eaddhelp
{
Write-Host "
NAME
      Nowsync External object add 

SYNOPSIS
    
      Performs initial baseline of Navision objects into GIT Repository.
      Workspace needs to be blank before you run this command.
      
SYNTAX     
        
      ns [eadd]"

     

Write-Host "	  
      Example: ns eadd
	  After development of any new external object the developer is required to add the object. 
	  Developer need to be enter the name of the file.`n`n" -ForegroundColor Green
}
Function ecihelp
{
Write-Host "
NAME
      Nowsync External Check-in 

SYNOPSIS
    
      Performs initial baseline of Navision objects into GIT Repository.
      Workspace needs to be blank before you run this command.
      
SYNTAX     
        
      ns [heci]"

     

Write-Host "	  
      Example: ns eci
	  After modifying any external object the developer is required to Check in the object on GIT.`n`n" -ForegroundColor Green
}

Function euphelp
{
Write-Host "
NAME
      Nowsync External update 

SYNOPSIS
    
      Performs initial baseline of Navision objects into GIT Repository.
      
      
SYNTAX     
        
      ns [eup]"

     

Write-Host "	  
      Example: ns eup
	  Before starting to work on the workspace, User needs to update to latest version of the external files.
	  He can do it by using eup`n`n" -ForegroundColor Green
}


Function eundohelp
{
Write-Host "
NAME
      Nowsync External undo 

SYNOPSIS
    
      Performs initial baseline of Navision objects into GIT Repository.
      Workspace needs to be blank before you run this command.
      
SYNTAX     
        
      ns [eundo]"

     

Write-Host "	  
      Example: ns eundo
	  After modifying any external object the developer want to rollback or he want to start again the object on GIT.
	  He can do it by using eundo`n`n" -ForegroundColor Green
}


Export-ModuleMember -Function abouthelp
Export-ModuleMember -Function cohelp
Export-ModuleMember -Function cihelp
Export-ModuleMember -Function ucohelp
Export-ModuleMember -Function ucihelp
Export-ModuleMember -Function combcihelp
Export-ModuleMember -Function lshelp
Export-ModuleMember -Function glhelp
Export-ModuleMember -Function blhelp
Export-ModuleMember -Function undohelp
Export-ModuleMember -Function eundohelp
Export-ModuleMember -Function euphelp
Export-ModuleMember -Function eaddhelp
Export-ModuleMember -Function ecihelp
Export-ModuleMember -Function ecohelp

Export-ModuleMember -Function Valfromconfig
$poweshellpath=Valfromconfig 'Powershell Path'