###########################################################
#
# Description: Script to Link Workitems
#
# Author:      Tushar Meshram
#
############################################################

# Get Start Time
$startDTM = (Get-Date)
$scriptName = $MyInvocation.MyCommand.Name
$scriptPath = $PSScriptRoot
$errLogFile = "$scriptPath\$(([io.fileinfo]"$scriptName").basename)_Error.log"
$tpcUrl = "http://ttraflon2k932:8080/tfs/Puma" #The Collection URL to change as per your requirement.
$csvfile="$scriptPath\WI.csv" #format: Parent, Child, ReferenceName
$list = Import-Csv $csvFile
$list = [array]$list
$linkHash = @{}

Write-Host "Script ${scriptName} Started`n"	-ForegroundColor Yellow

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.Client")
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.WorkItemTracking.Client")

$tpc = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tpcUrl)
$wis = $tpc.GetService([Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore])

#Removing already existing $errLogFile
if (test-path $errLogFile)
	{
		rm -force $errLogFile
	}	

#Creating an empty linkError file
New-Item -path $(split-path $errLogFile) -name $(([io.fileinfo]"${errLogFile}").Name) -type File -Force > $null

$i=1
foreach ($workItem in $list)
{
	$pwi=[int]$($workItem.Parent).trim()
	$cwi=[int]$($workItem.Child).trim()
	$linkType=$($workItem.ReferenceName).trim()
	
	$pwCheck=$wis.Query($("SELECT [System.Id] FROM WorkItems WHERE [System.Id] = $pwi"))
	$cwCheck=$wis.Query($("SELECT [System.Id] FROM WorkItems WHERE [System.Id] = $cwi"))	
	$message=$null
	if ([int]$pwCheck.Length -eq 0 -and [int]$cwCheck.Length -eq 0)
		{
		$message="Both ${pwi} and ${cwi} are not valid workitems"
		}
	elseif ([int]$pwCheck.Length -eq 0)
		{
		$message="${pwi} is not a valid workitem"
		}
	elseif ([int]$cwCheck.Length -eq 0)
		{
		$message="${cwi} is not a valid workitem"
		}
	
	$ValidLink="true"	
	switch($linkType)
	{
		"hierarchy"		{$hierarchyLink = $wis.WorkItemLinkTypes["System.LinkTypes.Hierarchy"]}
		"dependency"	{$hierarchyLink = $wis.WorkItemLinkTypes["System.LinkTypes.Dependency"]}
		"related"		{$hierarchyLink = $wis.WorkItemLinkTypes["System.LinkTypes.Related"]}
		"testedby"		{$hierarchyLink = $wis.WorkItemLinkTypes["Microsoft.VSTS.Common.TestedBy"]}
		"affects"		{$hierarchyLink = $wis.WorkItemLinkTypes["Microsoft.VSTS.Common.Affects"]}
		default 		{$ValidLink="false"}
	}
	
	if ($message -ne $null -and $validLink -eq "false") {$linkHash.failure++;Write-Host "${i}) ${linkType} Link failed between ${pwi} and ${cwi}" -ForegroundColor Red;$(echo "ERROR : $($linkHash.failure)";echo "Record Number in CSV File : ${i}";echo "$message & ${linkType} is not a valid link type between the work item ${pwi} and ${cwi}";echo "";echo "") >> $errLogFile; $i++; continue}	
	elseif ($message -eq $null -and $validLink -eq "false") {$linkHash.failure++;Write-Host "${i}) ${linkType} Link failed between ${pwi} and ${cwi}" -ForegroundColor Red;$(echo "ERROR : $($linkHash.failure)";echo "Record Number in CSV File : ${i}";echo "${linkType} : Not a valid link type between the work item ${pwi} and ${cwi}";echo "";echo "") >> $errLogFile; $i++; continue}	
	elseif ($message -ne $null -and $ValidLink -eq "true") {$linkHash.failure++;Write-Host "${i}) ${linkType} Link failed between ${pwi} and ${cwi}" -ForegroundColor Red;$(echo "ERROR : $($linkHash.failure)";echo "Record Number in CSV File : ${i}";echo "${message}";echo "";echo "") >> $errLogFile; $i++; continue}
	
	$childWIT = $wis.GetWorkItem($cwi)
	$link = new-object Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemLink($hierarchyLink.ReverseEnd, $pwi)    
   
    try
	{
		$childWIT.WorkItemLinks.Add($link) > $null
		$linkHash.success++
		Write-Host "${i}) ${linkType} Link created between ${pwi} and ${cwi}" -ForegroundColor DarkGreen
	}
	catch
	{ 	
		$linkHash.failure++
		Write-Host "${i}) ${linkType} Link failed between ${pwi} and ${cwi}" -ForegroundColor Red
		$(echo "ERROR : $($linkHash.failure)";echo "Record Number in CSV File : ${i}";echo "Could not create ${linkType} link between the work item ${pwi} and ${cwi}";echo "") >> $errLogFile
		echo $_ >> $errLogFile
		echo ""	>> $errLogFile
	}
		$childWIT.Save();
		$i++
}

if ($list.count -eq $([int]$linkHash.success)) 
	{
		Write-Host "Total records processed : $($list.count)" -ForegroundColor Green
		Write-Host "Total records success : $([int]$linkHash.success)" -ForegroundColor Green
		Write-Host "Total records failure : $([int]$linkHash.failure)" -ForegroundColor Green
		Write-Host "Linking complete" -ForegroundColor Green
	}
else
	{
		Write-Host "Total records processed : $($list.count)" -ForegroundColor Red
		Write-Host "Total records success : $([int]$linkHash.success)" -ForegroundColor Red
		Write-Host "Total records failure : $([int]$linkHash.failure). Error log file -> $errLogFile for more information." -ForegroundColor Red
		Write-Host "Linking complete" -ForegroundColor Red
		
	}

Write-Host "`nScript ${scriptName} Completed" -ForegroundColor Yellow	
# Get End Time
$endDTM = (Get-Date)	
# Echo Time elapsed
Write-Host "`Script Execution Time: $(($endDTM-$startDTM).totalminutes) minutes" -ForegroundColor Yellow
