#############################################################
#
# Description: Script to create the workspace in TFS server and map server branch to local folder in user's machine 
#
# Author:      Khushwant Singh
# Created:     30/09/2015
#############################################################

$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot
$workSpaceConfig="$scriptPath\workSpaceConfig.ps1"

####Sourcing WorkSpace Configuration file#####
. ${workSpaceConfig}
$env:PATH += ";${TfPath}"

$LocalWrkspacePath = $LocalWrkSpcMapFldr + $TeamProjectBranch.Substring(1).Replace("/","\")
								
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.Client")
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.VersionControl.Client")

function nowSyncAlias()
{
	##Alias creation in profile file
	Write-Host "Creating alias in `"${profile}`" file"  -ForegroundColor Green
	if (!(Test-Path $(split-path $profile) -pathType container))
		{
			Write-Host "Creating Folder : $(split-path $profile)"
			New-Item -ItemType directory -Path $(split-path $profile)
		}

	if (Test-path $profile)
		{
			Write-Host  "`"${profile}`" file is already present" -ForegroundColor Yellow 
			$outp=$(cat $profile) -match "^New-Alias\sns\s$([regex]::Escape($NowSyncScript))$"
			if (!($outp))
				{
					Write-Host "Adding Alias as `"ns`" for `"${NowSyncScript}`" in profile
					file" -ForegroundColor Green	
					Add-Content $profile  ""
					Add-Content $profile  "New-Alias ns ${NowSyncScript}"			
				}
			else
				{	
					Write-Host "Alias as `"ns`" for `"${NowSyncScript}`" is already present in profile file" -ForegroundColor Green        		
				}
		}		
	elseif (!(Test-path $profile))
		{
			Write-Host "`"${profile}`" file is not present" -ForegroundColor Yellow    
			Write-Host "Creating new `"${profile}`" file" -ForegroundColor Green 				
			Write-Host "Adding Alias as `"ns`" for `"${NowSyncScript}`" in profile file" -ForegroundColor Green
			Add-Content $profile  "New-Alias ns $NowSyncScript"
		}
}

function createWorkSpaceAndMap()
{		
	if (Test-Path $LocalWrkSpcMapFldr -pathType container)
		{
			$FileDirCount=$(Get-ChildItem ${LocalWrkSpcMapFldr}| Measure-Object).Count
			if ($FileDirCount -gt 0)
				{
					Write-Host "Local Folder `"$LocalWrkSpcMapFldr`" is not empty" -ForegroundColor Red
					Write-Host "Do you want to delete the contents inside the folder `"${LocalWrkSpcMapFldr}`" ? (Y/N) : " -ForegroundColor Yellow -NoNewline
					$choice = Read-Host	
					if ($choice -eq "y" -or $choice -eq "Y")
						{
							Write-Host "Deleting the contents inside Local Folder `"$LocalWrkSpcMapFldr`".Please wait..." -ForegroundColor Yellow
							rm -r $LocalWrkSpcMapFldr\* -Force
						}
					else 
						{
							Write-Host "Exiting the script..." -ForegroundColor Red
							exit 0
						}
				}
		}
		
		Write-Host "Connecting to $TFSCollection" -ForegroundColor Green
        $tfsCollectionObject = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($TFSCollection)
		$vcsObject = $tfsCollectionObject.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer])
        		
        Write-Host "Creating workspace : $workSpaceName associated with your system : $(hostname)" -ForegroundColor Green
        $tsfWorkspace2Create = $vcsObject.CreateWorkspace($workSpaceName)			
		Write-Host "Mapping TFS branch : $TeamProjectBranch to Local Workspace Folder : $LocalWrkspacePath" -ForegroundColor Green
        $tsfWorkspace2Create.Map($TeamProjectBranch, $LocalWrkspacePath)	
		$itemSpecFullTeamProj = New-Object Microsoft.TeamFoundation.VersionControl.Client.ItemSpec($TeamProjectBranch, "Full")
		Write-Host "Getting latest data from TFS branch : $TeamProjectBranch into Local Workspace Folder : $LocalWrkspacePath" -ForegroundColor Green
		$fileRequest = New-Object Microsoft.TeamFoundation.VersionControl.Client.GetRequest($itemSpecFullTeamProj,[Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest)
		$tsfWorkspace2Create.Get($fileRequest, [Microsoft.TeamFoundation.VersionControl.Client.GetOptions]::GetAll)				
		nowSyncAlias		
}

try
{			
		$wrkSpcOutput=$(tf workspaces /collection:$TFSCollection) -match "^${workSpaceName}\s+\w+.*\s+$(hostname)"
		if ($wrkSpcOutput)
			{
				Write-Host "WORKSPACE : `"$workSpaceName`" is already present and associated with your system : `"$(hostname)`"" -ForegroundColor Red
				Write-Host "Do you want to delete and recreate the WORKSPACE : `"${workSpaceName}`" ? (Y/N) : " -ForegroundColor Yellow -NoNewline
				$choice = Read-Host	
				if ($choice -eq "y" -or $choice -eq "Y")
					{
						tf workspace /delete ${workSpaceName} /collection:${TFSCollection} /noprompt
						createWorkSpaceAndMap				
					}
				else
					{
						Write-Host "Exiting the script..." -ForegroundColor Red
						Write-Host "...............Press any key to exit ..." -ForegroundColor Yellow
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
						exit 0
					}
			}		
		else
			{				
				createWorkSpaceAndMap
			}
}
catch [System.Exception]
{
    Write-Host "Exception: " ($Error[0]).Exception
	Write-Host "LASTEXITCODE : $LASTEXITCODE"
    EXIT $LASTEXITCODE
}

Write-Host "...............Press any key to exit ..." -ForegroundColor Yellow
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit 0