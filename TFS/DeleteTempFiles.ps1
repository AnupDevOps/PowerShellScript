#Log
Try{Stop-Transcript | Out-Null}catch [System.InvalidOperationException]{}
Start-Transcript -Path ($PSScriptRoot+"\Logs\DeletionLog-$($env:COMPUTERNAME).txt") -Force

#Size Before
Write-Host "Size before deletion: $("{0:N2}" -f ($(Get-ChildItem -Path $Env:temp -Recurse | Measure-Object -property length -sum).sum / 1MB) + " MB")"

#Delete Temp
Get-ChildItem -Path $Env:temp -Recurse | ForEach-Object {`
    Try
    {
        [string]$File = $PSItem.FullName
        Remove-Item -Path $PSItem.FullName -Force -ErrorAction Stop -Recurse
        Write-Host "INFO: $(Get-Date -Format "dd.M.yyyy->HH:mm:ss\h") Deleted: $($PSItem.FullName)"
    }
    Catch
    {
        If($($PSItem.Exception.GetBaseException().Message) -like "*is being used by another process*")
        {
            Write-Host "Waring: $(Get-Date -Format "dd.M.yyyy->HH:mm:ss\h") $($File): Is being used by another process"
        }
        Else
        {
            Write-Host "Error: $(Get-Date -Format "dd.M.yyyy->HH:mm:ss\h") $($PSItem.Exception.GetBaseException().Message)"
        }
    }
}

#Size After
Write-Host "Size after deletion: $("{0:N2}" -f ($(Get-ChildItem -Path $Env:temp -Recurse | Measure-Object -property length -sum).sum / 1MB) + " MB")"

Try{Stop-Transcript | Out-Null}catch [System.InvalidOperationException]{}