[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)][string]$DBServer,
  [Parameter(Mandatory=$True,Position=2)][string]$DBName,
  [Parameter(Mandatory=$True,Position=3)][string]$FolderPath
)
Set-StrictMode -Version 2.0
if (!(Test-Path -Path $FolderPath)){Write-Host "FolderPath could not be found" -ForegroundColor Red}
ForEach ($fileName In (Get-ChildItem -Path $FolderPath -Filter *.sql ))
{
    Write-Host ($fileName.Directory.ToString()+"\"+$filename.BaseName+".txt")
    $res=Invoke-Sqlcmd -ServerInstance $DBServer -Database $DBName -Query (Get-Content -Path $fileName.FullName.ToString() | Out-String)
    $res| Export-Csv -Path ($fileName.Directory.ToString() +"\"+$filename.BaseName+".csv") -Encoding UTF8 -Delimiter "°" -NoTypeInformation -Verbose
}