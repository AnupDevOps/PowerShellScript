[CmdletBinding(SupportsShouldProcess=$True)]
Param(
        [Parameter(Mandatory=$true,Position=1)]
        [String[]]$PathsToDelete=[String]::empty
)
Set-StrictMode -Version Latest -Verbose
$PathsToDelete | ForEach-Object -Process `
{
    Get-ChildItem -Path ($PSItem+"\*") -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue
}