$ErrorActionPreference="Stop"
$InformationPreference="Continue"
try
{
    [String]$strBuildDir=(Get-ChildItem -Path Env:\BUILD_ARTIFACTSTAGINGDIRECTORY | Select-Object -ExpandProperty Value).toString()
}
catch
{
    Write-Error -Message "Environment variable on BuildServer BUILD_ARTIFACTSTAGINGDIRECTORY called  could not be found"
}
if (Test-Path -Path $strBuildDir -PathType Container)
{
    Write-Information -MessageData ("The staging path could be found and accessed.:"+$strBuildDir)
}
else
{
    Write-Error -Message ("Path could not be found at: "+$strBuildDir)
}
Write-Information -MessageData ("Determined Volume: "+((Get-Item -Path $strBuildDir.Trim()).Fullname.ToString()).Split(":")[0])
[Double]$dblFreeDiskSpace=[Math]::Round((Get-Volume -DriveLetter (((Get-Item -Path $strBuildDir.Trim()).Fullname.ToString()).Split(":")[0]) | Select-Object -ExpandProperty SizeRemaining)/1Gb,3)
If($dblFreeDiskSpace -ge 15)
{
    Write-Information -MessageData "The disk space on the Volume is more than $($dblFreeDiskSpace.toString()) Gb. This is sufficient to continue with the build"
    return $true
}
else
{
    Send-MailMessage -From Sender-Mail-ID -to "receiver-Mail-ID" -Cc @("Mail-ID-User1","Mail-ID-User2")  `
        -Body ("Not enough disk space on Drive "+((Get-Item -Path $strBuildDir.Trim()).Fullname.ToString()).Split(":")[0]+"`nLower than $($dblFreeDiskSpace.ToString()) on "+`
        (Get-ChildItem -Path Env:\Agent.Name | Select-Object -ExpandProperty Value).toString()) `
        -Subject BuildIssue -UseSsl -Port 465 -SmtpServer t-mail-avg-gw.tadnet.net
    Write-Error -Message "The disk space is lower than $($dblFreeDiskSpace.toString()). This is not sufficient to continue with the build. Aborting..."
    return $false
}