#variables to Change to Run the Build #

$Source="2_9"	
$target="2_10" 
####################################################


$newtonsoft = import-module Newtonsoft.Json -ErrorAction SilentlyContinue -PassThru
if(!$newtonsoft)
{
    (New-Object -TypeName System.Net.WebClient).Proxy.Credentials= [System.Net.CredentialCache]::DefaultNetworkCredentials
    Install-Module Newtonsoft.Json -Scope CurrentUser -Force
    Import-Module Newtonsoft.Json
}

$baseUrl = "TFS-UR:"
$targetCollection = "Collection-Name"
$targetProject = "Project-Name"

$definitionsOverviewUrl = "$baseUrl/$targetCollection/$targetProject/_apis/build/Definitions"

$definitionsOverviewResponse = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionsOverviewUrl

$definitionsOverview = (ConvertFrom-Json $definitionsOverviewResponse.Content).value


$targetBuildName="New-Build-Name"

$definitionUrl = ($definitionsOverview | Where-Object { $_.name -eq $targetBuildName } | Select-Object -First 1).url

$response = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionUrl

$buildDefinition = ConvertFrom-JsonNewtonsoft -string $response

#$buildDefinition

$buildDefinition.id = 0
$buildDefinition.name = "OLD-TFS-Build"
$buildDefinition.path = "\$target"


$serialized = ConvertTo-JsonNewtonsoft -obj $buildDefinition -Verbose

$postData = [System.Text.Encoding]::UTF8.GetBytes($serialized)

# The TFS2015 REST endpoint requires an api-version header, otherwise it refuses to work properly.
$headers = @{ "Accept" = "api-version=2.3-preview.2" }

$createURL = $definitionsOverviewUrl + "?api-version=2.3-preview.2"
$response = Invoke-WebRequest -UseDefaultCredentials -Uri $createURL -Headers $headers -Method Post -Body $postData -ContentType "application/json"

$response.StatusDescription

########################################################################################
########################Edit Build Definition###################################################
########################################################################################

$definitionsOverviewUrl = "$baseUrl/$targetCollection/$targetProject/_apis/build/Definitions"

$definitionsOverviewResponse = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionsOverviewUrl

$definitionsOverview = (ConvertFrom-Json $definitionsOverviewResponse.Content).value

$targetBuildName="New TFS-Build"

$definitionUrl = ($definitionsOverview | Where-Object { $_.name -eq $targetBuildName } | Select-Object -First 1).url

#$definitionUrl = ($definitionsOverview | Where-Object { $_.name -contains 'R_2_6*' } | Select-Object -First 1).url


$response = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionUrl

$buildDefinition = ConvertFrom-JsonNewtonsoft -string $response

$buildDefinition.variables.Release.value = "$target"
#$buildDefinition.variables.Buildnumber.value= "270"


#$buildDefinition.demands="QA"
#$buildDefinition.demands="Anything"

#$mochaStep = $buildDefinition.build | Where-Object { $_.displayName -eq "test run mocha" }
#$mochaStep.enabled = "True"

$serialized = ConvertTo-JsonNewtonsoft -obj $buildDefinition -Verbose

$postData = [System.Text.Encoding]::UTF8.GetBytes($serialized)

# The TFS2015 REST endpoint requires an api-version header, otherwise it refuses to work properly.
$headers = @{ "Accept" = "api-version=2.3-preview.2" }

$response = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionUrl -Headers $headers -Method Put -Body $postData -ContentType "application/json"

$response.StatusDescription 

########################################################################################
######################## Edit Build  trigger Definition ################################
########################################################################################

$releaseFrom = "$Source"
$releaseTo = "$target"

$definitionsOverviewUrl = "$baseUrl/$targetCollection/$targetProject/_apis/build/Definitions"

$definitionsOverviewResponse = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionsOverviewUrl

$definitionsOverview = (ConvertFrom-Json $definitionsOverviewResponse.Content).value


$targetBuildName="New TFS-Build" 

$definitionUrl = ($definitionsOverview | Where-Object { $_.name -eq $targetBuildName } | Select-Object -First 1).url

$response = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionUrl

$buildDefinition = ConvertFrom-JsonNewtonsoft -string $response

$triggers = ($buildDefinition.triggers | where { $_.triggerType -eq "continuousIntegration" })

$newFilters = $triggers.pathFilters | % { $_ -replace ($releaseFrom, $releaseTo)} 

$triggers.pathFilters = $newFilters

$serialized = ConvertTo-JsonNewtonsoft -obj $buildDefinition -Verbose

$postData = [System.Text.Encoding]::UTF8.GetBytes($serialized)

# The TFS2015 REST endpoint requires an api-version header, otherwise it refuses to work properly.
$headers = @{ "Accept" = "api-version=2.3-preview.2" }

$response = Invoke-WebRequest -UseDefaultCredentials -Uri $definitionUrl -Headers $headers -Method Put -Body $postData -ContentType "application/json"
# $response = Invoke-WebRequest -UseDefaultCredentials -Uri $createURL -Headers $headers -Method Post -Body $postData -ContentType "application/json"

$response.StatusDescription 

 
