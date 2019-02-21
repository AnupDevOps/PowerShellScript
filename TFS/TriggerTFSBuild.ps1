$body = '
{ 
"definition":
{
"id": $buildId  # TFS Build ID 
} 
}
'
$bodyJson=$body | ConvertFrom-Json
Write-Output $bodyJson
$bodyString=$bodyJson | ConvertTo-Json -Depth 100
#Write-Output $bodyString

$Uri = "TFS-URL/_apis/build/builds/?api-version=2.0"

$buildresponse = Invoke-RestMethod -Method Post -UseDefaultCredentials -ContentType application/json -Uri $Uri -Body $bodyString-UseDefaultCredentials
write-host $buildresponse 
