# Release Management Deployment Script
if (Test-Path -Path __LogFile__ -PathType Leaf)
		{
			Remove-Item __LogFile__ -Force
		}
			
if (Test-Path -Path __importFile__ -PathType Leaf)
		{
			$importfinsqlcommand = """__NAVFolder__\finsql.exe"" command=importobjects,file=__importFile__,navservername=__NavServer__,navserverinstance=__NavInstance__,navservermanagementport=__NavPort__,ntauthentication=yes,servername=__Server__,database=__Database__,importaction=overwrite,Logfile=__LogFile__,synchronizeschemachanges=force"
			Write-Debug $importfinsqlcommand
			cmd /c $importfinsqlcommand

		}
		
if (!(Test-Path -Path __LogFile__ -PathType Leaf))
			{
				Write-Host "Deployment Successful" -ForegroundColor Green
				Remove-Item __importFile__ -Force
			}
	else
			{
				Write-Host "Deployment Failed" -ForegroundColor Red
				Write-Host "Content of __LogFile__ is displayed below" -ForegroundColor Red
				cat __LogFile__
				exit 1
			}


#####################################################################
############# Automation Input Xml #################################
#####################################################################

$xml_file_path="__FilePath__\Automation_input_xml"

Copy-Item -Path "${xml_file_path}/*" "__FilePath__/../Automation_input_xml/" -recurse -Force

Set-ItemProperty "__FilePath__/../Automation_input_xml/*" -name IsReadOnly -value $false


<# foreach ($codeData in Get-Content "C:\Automation_input_xml\automation_xml_input.txt" ) 
				{
					cd "C:\Program Files (x86)\Microsoft Dynamics NAV\80\RoleTailored Client"
					./Microsoft.Dynamics.Nav.Client.exe -consolemode "DynamicsNAV://__ServerName__:__NavClientPort__/__ServerInstance__/AUN/RunCodeUnit?CodeUnit=$codeData"  -ShowNavigationPage:0
					write-host "$codeData CodeUnit will open soon" -ForegroundColor Yellow -background Black
				} #>