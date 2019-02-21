$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot


$wspath="${Env:BUILD_REPOSITORY_LOCALPATH}"	
$NAVFolder="C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client"
$build_name="${Env:BUILD_DEFINITIONNAME}"

$binarydest="\\ttrafloco2k910\BINARIES\ePuma\GIT\$build_name\Latest"

$fobbuildfile="\\ttrafloco2k910\BINARIES\ePuma\GIT\$build_name\Latest\${Env:BUILD_BUILDNUMBER}.fob"
$LogFile="C:\$build_name\Log\import.log"
$Logfolder="C:\$build_name\Log"
$FullLogFile="C:\$build_name\Log\full_compile.log"
$outputFile = Split-Path $fobbuildfile -leaf


### Function to get the Traget Environment Details Ex: Database name etc.

function Valfromconfig()
{   
[CmdletBinding()]
    param 
    (
        [String]$variable        
    )            
$string = $(Get-Content "\\ttrafloco2k910\BINARIES\ePuma\GIT\target_env.txt" | Select-String $variable).ToString().split("=")[1]
return $string
}

$Server=Valfromconfig 'Dev_DBServer'
$Database=Valfromconfig 'Dev_Database'
$navservername=Valfromconfig 'navservername'
$navserverinstance=Valfromconfig 'navserverinstance'
$navservermanagementport=Valfromconfig 'navservermanagementport'

#$DriveLetter="C"
#New-item -Path "\\dpumaloco2k18\C$\$build_name" -type directory -Force
#Remove-Item "\\dpumaloco2k18\C$\$build_name\*" -Recurse -Force
#New-item -Path "\\dpumaloco2k18\C$\$build_name\Log" -type directory -Force


######## Extraction of Master Config file ############
Add-Type -Assembly "System.IO.Compression.FileSystem" ;
[System.IO.Compression.ZipFile]::ExtractToDirectory("$binarydest\Master_Config_Package.zip", "C:\$build_name") ;
New-item -Path "C:\$build_name\Log" -type directory -Force


#### Call Creation xml Script  ####

Invoke-Expression $scriptPath\Creation_xml.ps1

$datetime = Get-Date
Write-Host "Import Object on Target Machine Start  time " $datetime

$finSqlCommand = """$NAVFolder\finsql.exe"" command=importobjects,file=$fobbuildfile,servername=$Server,database=$Database,synchronizeschemachanges=force,importaction=overwrite,Logfile=$LogFile, navservername=$navservername, navserverinstance=$navserverinstance, navservermanagementport=$navservermanagementport"
Write-Debug $finSqlCommand
cmd /c $finSqlCommand

$datetime = Get-Date
Write-Host "Import Object on Target Machine End time " $datetime

##### Start of Full Compilation on Target Machine ######

$datetime = Get-Date
Write-Host "Compilation on Target Machine Start time " $datetime
				if (Test-Path "$Logfolder\navcommandresult.txt") 
					{
						Remove-Item "$Logfolder\navcommandresult.txt"
					}				

				Write-Host "Full Compilation started" -ForegroundColor Yellow
				$finSqlCommand = """$NAVFolder\finsql.exe"" command=compileobjects,servername=$Server,database=$Database,synchronizeschemachanges=force,Logfile=$FullLogFile, navservername=$navservername, navserverinstance=$navserverinstance, navservermanagementport=$navservermanagementport"
				Write-Debug $finSqlCommand
				cmd /c $finSqlCommand
				
$datetime = Get-Date
Write-Host "Compilation on Target Machine End time " $datetime

#### End of Full Compilation on Target Machine ####
if (Test-Path $FullLogFile) 
					{   
						Write-Host "Some Compilation errors for full compilation. Check log for more detail" -ForegroundColor Red
						exit 0
					}
				else
					{        
						Write-Host "Full Compilation completed successfully" -ForegroundColor Green
						exit 0															
					}	

# Delete Objects whch are not in GIT Version Control

	<# $sqlConnection = new-object System.Data.SqlClient.SqlConnection "server=$Server;database=$Database;Integrated Security=sspi"
	$sqlConnection.Open()
	$sqlCommand = $sqlConnection.CreateCommand()
	$sqlCommand.CommandText ="delete  from [Object] where [Version List]!='$outputFile'"
	$sqlReader = $sqlCommand.ExecuteReader()
	$sqlConnection.Close() #>