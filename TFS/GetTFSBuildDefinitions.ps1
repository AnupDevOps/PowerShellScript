cls

$newtonsoft = import-module Newtonsoft.Json -ErrorAction SilentlyContinue -PassThru
if(!$newtonsoft)
{
    (New-Object -TypeName System.Net.WebClient).Proxy.Credentials= [System.Net.CredentialCache]::DefaultNetworkCredentials
    Install-Module Newtonsoft.Json -Scope CurrentUser -Force
    Import-Module Newtonsoft.Json
}

$baseUrl = "TFS-Base_Url"
$targetCollection = "Collection-NAme"
$targetProject = "Project-Name"
$targetPath = "\2_8\vertical"

$definitionsOverviewUrl = "$baseUrl/$targetCollection/$targetProject/_apis/build/Definitions"

$definitionsOverviewResponse = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionsOverviewUrl

$definitionsOverview = (ConvertFrom-Json $definitionsOverviewResponse.Content).value

$definitionUrls = ($definitionsOverview | Where-Object { $_.path -eq $targetPath }).url
$definitionUrls 
