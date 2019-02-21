#######################################################################
############ Release Management Deployment Script ######################
############ Target Branch : Dev (Test10) ######################
#######################################################################
$build_name=$env:BUILD_DEFINITIONNAME
$bnumber="${Env:BUILD_BUILDNUMBER}"

$navserver="$Env:sfnavserver"
$server="$Env:sfserver"
$servername= "$Env:sfservername"
$Database="$Env:sfDatabase"
$NavPort="$Env:sfNavPort"

$versionlist="${Env:BUILD_BUILDNUMBER}"

$NAVFolder="C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client"
$importFile="$env:SYSTEM_ARTIFACTSDIRECTORY\$env:BUILD_DEFINITIONNAME\CopyArtifact\RM.fob"
$Logfile="$env:SYSTEM_ARTIFACTSDIRECTORY\$env:BUILD_DEFINITIONNAME\CopyArtifact\log.log"
echo $navserver
echo $server
echo $database
echo $NavPort
if (Test-Path -Path $importFile -PathType Leaf)
		{
			$importfinsqlcommand = """$NAVFolder\finsql.exe"" command=importobjects,file=$importFile,navservername=$navserver,navserverinstance=$Database,navservermanagementport=$NavPort,ntauthentication=yes,servername=$server,database=$Database,importaction=overwrite,synchronizeschemachanges=force, Logfile=$Logfile"
			Write-Debug $importfinsqlcommand
			cmd /c $importfinsqlcommand
			
			$compilefinsqlcommand = """$NAVFolder\finsql.exe"" command=compileobjects,navservername=$navserver,navserverinstance=$Database,navservermanagementport=$NavPort,ntauthentication=yes,servername=$server,database=$Database,importaction=overwrite,synchronizeschemachanges=force, Logfile=$Logfile, filter=Version List='$versionlist C'"
			Write-Debug $compilefinsqlcommand
			cmd /c $compilefinsqlcommand
		}
	else
	{
		write-host "No fob Found "
	}
	
