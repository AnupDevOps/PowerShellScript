	$project="TFS-Project-URl-Till-Project_name"
$url=  $project + '/_apis/wit/workitems/$task?api-version=2.0'
	$title="Title header"


	    $body=@"
            [
                {
                    "op": "add",        
                    "path": "/fields/System.Title",         
                    "value": "Creating the TFS Tasks"
                },
                {
                    "op": "add",        
                    "path": "/fields/System.Description",          
                    "value": "API TEST"
                },
                {
                    "op": "add",        
                    "path": "/fields/System.AssignedTo",           
                    "value": "User_details"
                },
                {
                    "op": "add",        
                    "path": "/fields/System.AreaPath",     
                    "value": "TFS Area Path"
                },
                {
                    "op": "add",        
                    "path": "/fields/System.IterationPath",        
                    "value": "TFS-IterationPath"
                }

            ]
"@


	Write-Host "$url"

	$response= Invoke-RestMethod -UseDefaultCredentials -Uri $url  -ContentType "application/json-patch+json" -Body $body -Method PATCH

	#$response= Invoke-RestMethod -UseDefaultCredentials -Uri $url  -ContentType "application/json-patch+json" -Body $body -headers $headers -Method PATCH 
	Write-Host $response