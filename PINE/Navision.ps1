echo "Get the CheckOut Version ${Env:TF_BUILD_SOURCEGETVERSION}"

$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot
echo $scriptName
echo $scriptPath

if(Test-Path D:\Docsa)
    {
        write-host "Document folder is there" -ForegroundColor Green
    }
else
    {
        Write-Host "Document folder is not there" -ForegroundColor Red
    }

