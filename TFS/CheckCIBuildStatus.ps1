$dir="${ENV:build.sourcesDirectory}"
$BNumber="${ENV:Buildnumber}"
$build="$Env:BUILD_SOURCESDIRECTORY"
$Success='"status":"completed","result":"succeeded"'
$fail='"status":"completed","result":"failed"'
$inprogress='"status":"inProgress"'
$notstarted='"status":"notStarted"'
$uri = "TFS_Path/_apis/build/builds?definitions="
$uri2="&`$top=1"
$wc = New-Object System.Net.WebClient
$wc.UseDefaultCredentials = $true
$url=$uri+$BNumber+$uri2
[String]$status=[String]::Empty


while (([String]::IsNullOrEmpty($status)))

{

$json = $wc.DownloadString($url)
$Successed = $json | Select-String $Success -SimpleMatch -quiet -casesensitive
$failed = $json | Select-String $fail -SimpleMatch -quiet -casesensitive
 

if ((-not[String]::IsNullOrEmpty($Successed)))
{ 
   Write-Host "Last CI Build has been sucessfull, Executes release tasks" -ForegroundColor DarkGreen
   Write-Host "##vso[task.complete result=Succeeded;]Done" 
   $status="completed"
}

elseif ((-not[String]::IsNullOrEmpty($failed)))

{
 Write-Host "Last CI Build has been failed" -BackgroundColor DarkRed
 Write-Host "##vso[task.complete result=SucceededWithIssues;]Failed" 
 $status="Failed"

}

else 

{
 write-host "CI build is in progress, Waiting for completion of build"
 Start-Sleep 180

$json = $wc.DownloadString($url)
$Successed = $json | Select-String $Success -SimpleMatch -quiet -casesensitive
$failed = $json | Select-String $fail -SimpleMatch -quiet -casesensitive

}

}






 
