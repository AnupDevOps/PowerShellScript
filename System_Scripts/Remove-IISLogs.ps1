#Simple script to delete the log files from IIS after x days
#TODO: Synopsis
[CmdletBinding(SupportsShouldProcess=$True)]
Param
(
    [Parameter(Mandatory=$True,Position=1)][String]$WebsiteName,
    [Parameter(Mandatory=$False,Position=2)][int16]$DeleteOlderThanXDays=160
)
#general functions
function Get-WebsiteLogDirectory
{
    [CmdletBinding(SupportsShouldProcess=$False)]
    [OutputType([Boolean])]
    Param
    (
        [Parameter(Mandatory=$True,Position=1)][String]$WebsiteName,
        [Parameter(DontShow)][String]$LogPath
    )

    if((Get-Module -ListAvailable | Where-Object -FilterScript {$PsItem.Name -ieq "WebAdministration"} | `
        Measure-Object | Select-Object -ExpandProperty Count) -lt 1)
    {
        Write-Error -Message "WebAdministration Module cannot be found...."
    }
    elseif((Get-WindowsFeature -Name Web-Server | Select-Object -ExpandProperty InstallState) -ine "Installed" )
    {
        Write-Error -Message "IIS is not installed properly."
    }
    if((Get-Service -Name W3Svc | Where-Object -FilterScript {$PsItem.Status -ieq "Running"} | `
        Measure-Object | Select-Object -ExpandProperty Count) -lt 1)
    {
        Write-Error -Message "IIS service seems to be stopped"
    }
    Write-Information -MessageData "IIS seems to be healthy. Starting to determine whether specified WebSite exists"
    if((Get-Website -Name $WebsiteName | Measure-Object | Select-Object -ExpandProperty Count) -lt 1)
    {
        Write-Error -Message "Website: $WebsiteName was not found"
    }
    else
    {
        Write-Information -MessageData "Website: $WebsiteName could be found. Starting to determine log path"
        $Logpath=(Get-Item -Path ("IIS:\Sites\"+$WebsiteName) | Select-Object -ExpandProperty LogFile | Select-Object -ExpandProperty directory)
    }
    
    return [String]$LogPath #SingleObject
}
function Start-Logging
{
    [CmdletBinding(SupportsShouldProcess=$False)]
    Param
    (
        [Parameter(Mandatory=$false,Position=1)][String]$LogFilePath,
        [Parameter(Mandatory=$false,Position=2)][Boolean]$OverwriteLogFile=$false
    )
    if([String]::IsNullOrEmpty($LogFilePath))
    {
        $LogFilePath=(Join-Path -Path $PSScriptRoot -ChildPath Log)
        Write-Information -MessageData "Log file variable was not provided. Script root path\logs will be used." -Tags Log
        if (-not(Test-Path -Path ($LogFilePath) -PathType Container))
        {
            try 
            {
                New-Item -Path $LogFilePath.TrimEnd("\Log") -Name "Log" -ItemType Directory -Force    
            }
            catch 
            {
                Write-Error -Exception ([System.io.DirectorynotFoundException]::new("LogDir not found")) -Message "The LogDir could not be found in $LogFilePath" `
                    -RecommendedAction "Check if PS runs under elevated UAC, check file permissions to target folder." -TargetObject $LogFilePath
            }
            Write-Information -MessageData "$LogFilePath was not found, created subfolder logs" -Tags Log
        }
    }
    try
    {
      Stop-Transcript | Out-Null
    }
    catch [System.InvalidOperationException]{}
    [String]$LogFileFullPath=((Join-Path -Path $LogFilePath `
        -ChildPath ("IMAS-log-"+((Get-ChildItem -Path env:computername).value.toString())))+ ".txt")
    if(-not(Test-Path -Path $LogFileFullPath -PathType Leaf))
    {
        try 
        {
            New-Item -Path $LogFilePath -Name (("IMAS-log-"+((Get-ChildItem -Path env:computername).value.toString()))+".txt") `
                -ItemType File -Force
        }
        catch 
        {
            Write-Error -Exception ([System.io.filenotFoundException]::new("LogFile not found")) -Message "The LogFile could not be found in $LogFileFullPath" `
                -RecommendedAction "Check if PS runs under elevated UAC, check file permissions to target folder." -TargetObject $LogFileFullPath        
        }
    }
    else
    {
        Write-Information -MessageData "LogFile $LogFileFullPath already existed."
    }
    if($OverwriteLogFile)
    {
        Remove-Item -Path $LogFileFullPath -Force -ErrorAction SilentlyContinue
        Start-Transcript -Path ($LogFileFullPath+[GUID]::NewGuid().toString()) -Force 
    }
    else
    {
        Start-Transcript -Path $LogFileFullPath -Append -Force    
    }
    Write-Information -MessageData "LogFile can be found in $LogfileFullPath" -Tags Log
    #ExecutionPolicy change
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    if((Get-ExecutionPolicy -Scope Process) -ieq "Bypass")
    {
        Write-Information -MessageData "Execution policy scope change successfull." -Tags ExecutionPolicy   
    }
    else 
    {
    Write-Warning -Message "Execution policy changed to ByPass for Scope CurrentUser was not successful."
    }
}#Returns nothing
function Clear-Variables
{
    [CmdletBinding(SupportsShouldProcess=$False)]
    Param
    (
        [Parameter(Mandatory=$true,Position=1)][String[]]$Vars
    )
    Compare-Object -ReferenceObject $Vars -DifferenceObject ([String[]]((Get-Variable | Select-Object -Unique -Property Name).Name)) | `
    Where-Object -FilterScript {$PsItem.SideIndicator -eq '=>'} | Select-Object -ExpandProperty InputObject | `
    ForEach-Object -Process `
    {
        if ((Get-Variable -Name ($PsItem)).Value -is [System.IDisposable])
        {
            Write-Information -MessageData ("Disposing Var:`t"+$PsItem) -Tags Disposal
            (Get-Variable -Name $PsItem).Value.dispose()
        } 
    }
}

[String[]]$strVars=(Get-Variable | Select-Object -Property Name -Unique).name #Must be the first Var in the script!
$Global:WhatIfPreference=$false
$Script:ErrorActionPreference = "Stop"
$Script:InformationPreference = "Continue"
$Script:WarningPreference = "Continue"
If($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -or $IsVerbose){$Script:VerbosePreference = "Continue";Write-Host "Verbose output enabled"}else{$Script:VerbosePreference = "SilentlyContinue"}
if($PSCmdlet.MyInvocation.BoundParameters["Debug"].IsPresent -or $IsDebug){$Script:DebugPreference = "Continue";Write-Host "Debug output enabled"}else{$Script:DebugPreference = "SilentlyContinue"}
$Script:IsSimulated=(-not($PSCmdlet.ShouldProcess($env:COMPUTERNAME)))#If IsSimulated=true then Whatif parameter was set [System.Boolean]$HasFailure=$false
[System.Object[]]$tmp
$WebsiteName=$WebsiteName.Trim()
Start-Logging -LogFilePath $PSScriptRoot\Logs
Get-ChildItem -Path (Get-WebsiteLogDirectory -WebsiteName $WebsiteName) -Filter *.* -Recurse| `
    Where-Object -FilterScript {$PsItem.CreationTime -lt (Get-Date).AddDays(-$DeleteOlderThanXDays)} | `
    Remove-Item -Verbose -Force -WhatIf -Recurse:$true -Exclude directory
Clear-Variables -Vars ($strVars)
Stop-Transcript -ErrorAction SilentlyContinue 
Write-Host "End of Script"