#Log
Try{Stop-Transcript | Out-Null}catch [System.InvalidOperationException]{}
Start-Transcript -Path ($PSScriptRoot+"\Logs\WSDeletionLog-$($env:COMPUTERNAME).txt") -Force

#Get local workspaces
[System.Object[]]$LocalBuilds = Get-PSDrive | `
    Where-Object -FilterScript {$PSItem.Provider.Name -eq "FileSystem" -and $PSItem.Name -ne "C" -and $PSItem.Name -ne "D" -and $PSItem.Name -ne "E"} | `
    ForEach-Object -Process `
    {
        If (Test-Path -Path "$($PSItem.Root)w*\SourceRootMapping" -PathType Container)
        {
            (Get-ChildItem -Path "$($PSItem.Root)w*\SourceRootMapping" -Recurse | Where-Object -FilterScript {$PSItem.Name -eq "SourceFolder.json"}).FullName | `
            ForEach-Object -Process `
            {
                $Path = ($PSItem.Split("\")[0])+"\"+($PSItem.Split("\")[1])+"\"
                Get-Content -Path $PSItem | ConvertFrom-Json | Select-Object -Property definitionName, agent_builddirectory, `
                                          @{Name="path";Expression={$Path+$PSItem.agent_builddirectory}}, collectionID, definitionID                                
            }
    }
}

#Get TFS Builds
[System.Object[]]$TFSBuilds = ((Invoke-WebRequest -Uri "TFSURL/_apis/build/definitions?api-version=2.0" -UseDefaultCredentials).content | ConvertFrom-Json).value.name

#Compare
[System.Object[]]$BuildsToDelete = (Compare-Object -ReferenceObject $($TFSBuilds | Sort-Object -Descending) `
    -DifferenceObject $($LocalBuilds.definitionname | Sort-Object -Descending -Unique) | `
    Where-Object -FilterScript {$PSItem.SideIndicator -like "=>"}).InputObject | `
    ForEach-Object {
        [String]$BuildName = $PSItem
        $LocalBuilds | Where-Object -FilterScript {$PSItem.definitionName -eq $BuildName}
}

#Delete VS WS
[String]$TFexe = "F:\Programs\VS2017\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer"
Start-Process -FilePath "$TFexe\tf.exe" `
    -ArgumentList "workspaces /format:detailed /collection:`"TFS-Collection-url`"" `
    -NoNewWindow -RedirectStandardOutput "$PSScriptRoot\Logs\stdout-$($env:COMPUTERNAME).txt" -Wait
$TF = Get-Content -Path "$PSScriptRoot\Logs\stdout-$($env:COMPUTERNAME).txt" | Where-Object -FilterScript {$PSItem -like "*Workspace  : *" -or $PSItem -like "*$/Development*"}
$WS = Get-Content -Path "$PSScriptRoot\Logs\stdout-$($env:COMPUTERNAME).txt" | Where-Object -FilterScript {$PSItem -like "*Workspace  : *"}
$WS += "EOF"
[System.Collections.Hashtable]$VSWorkspaces = @{}
[String]$Key = ""
[String]$Value = ""
Foreach ($Workspace in $WS)
{
    Foreach ($Path in $TF[($TF.IndexOf($Workspace))..$TF.Length])   
    {
        If ($Path -like "*$Workspace*"){$Key = $Workspace}
        ElseIf ($Path -like "*$/Development*"){$Value += $Path}
        Else
        {
            $VSWorkspaces.Add($Key.Replace("Workspace  : ","").Trim(),$Value) 
            $Value = ""
            Break                    
        }
    }
}
Write-Host "+++++++++++++ Visual Studio WS mappings" -ForegroundColor Cyan
$VSWorkspaces.GetEnumerator() | ForEach-Object {
    $WS = $PSItem.Key
    $WSpath = $PSItem.Value
    Foreach ($Path in $BuildsToDelete.path)
    {
        If ($WSpath -like "*$Path\*")
        {
            Write-Host "Delete WS mapping in VS: $WS -- $($WSpath.ToString().Split(" ")[2].Split("$")[0])"
            Try{Start-Process -FilePath "CMD" -ArgumentList "/c echo yes | `"$TFexe\tf.exe`" workspace /delete $WS;`"Project Collection Build Service`"" -Wait}
            Catch{Write-Host "Error while deleting $($PSItem.path): $($PSItem.Exception.GetBaseException().Message)" -ForegroundColor Red}
        }
    }
}

#Delete Folder
Write-Host "+++++++++++++ Local Working Directories" -ForegroundColor Cyan
$BuildsToDelete | ForEach-Object {
    Write-Host "Delete local Working Directory: $($PSItem.path) -- $($PSItem.definitionName)"
    Try
    {
        Remove-Item -Path $($PSItem.path) -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$(($PSItem.path).Replace($($PSItem.agent_builddirectory),`"`"))SourceRootMapping\$($PSItem.collectionId)\$($PSItem.definitionId)" -Recurse -Force -ErrorAction SilentlyContinue
        
    }
    Catch{Write-Host "Error while deleting $($PSItem.path): $($PSItem.Exception.GetBaseException().Message)" -ForegroundColor Red}
}

Try{Stop-Transcript | Out-Null}catch [System.InvalidOperationException]{}