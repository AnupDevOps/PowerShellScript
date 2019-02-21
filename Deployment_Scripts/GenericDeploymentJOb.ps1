Using namespace System.data
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$false,Position=1)]
  [string]$strEnv="PLYT0"
)
Set-StrictMode -Version 2.0 -Verbose
[string]$authType=""
[String]$strSQL="SELECT ALL * FROM [UDFRetrieveBasicDeployString]('$((Get-ChildItem -Path Env:AppType2x).Value.ToString())','$strEnv')"
[String]$strCon=(Get-ChildItem -Path Env:ConStringGov).Value.ToString()
[String[]]$strArray=@()
[System.Int16]$int=0
[SqlClient.SqlConnection]$con=New-Object System.Data.SqlClient.SqlConnection($strCon)
[SqlClient.SqlDataAdapter]$da=New-Object SqlClient.SqlDataAdapter((New-Object SqlClient.SqlCommand($strSQL,$con)))
[DataSet]$ds=New-Object DataSet
[DataColumn]$col=New-Object DataColumn
if ($con.State -eq [System.Data.ConnectionState]'Closed'){$con.Open()}
$da.Fill($ds)
if ($ds -eq $null){throw "DataSet was null";exit 99}
if ($con.State -ne [System.Data.ConnectionState]'Closed'){$con.Close()}
[DataRow[]]$rows=$ds.Tables[0].Select("ParameterName LIKE 'DropZone%'")
if ($rows.Count -lt 1){throw "SQL Query returned no value";exit 99}
$authType=(&{if ($rows[0].TargetServer.Contains("ESCB")){"Basic"} else {"NTLM"}})
[string]$argList="-source=package='"+($rows[0].Item("ParameterValue").toString())+"' -dest:auto,computerName='https://"+($rows[0].Item("TargetServer").toString())+":"+($rows[0].Item("TargetPort").toString())+"/msdeploy.axd?site="+($rows[0].Item("IIS Web Application Name").toString())+"',authtype='"+`
                    $authType+"'," + (&{If($rows[0].TargetServer.Contains("ESCB")){"getCredentials='$((Get-ChildItem -Path Env:Credentials).value.ToString())',"} Else {""}})+`
                    "includeAcls='False' -verb=sync -disableLink=AppPoolExtension -disableLink=ContentExtension -disableLink=CertificateExtension " + `
                    (&{If(((Get-ChildItem -Path Env:IsSimulated).value.ToString() -eq "true")){"-whatif "} Else {""}})+' -verbose '
ForEach ($row In $ds.Tables[0].Select("ParameterName NOT LIKE 'DropZone%'"))
{
    if (($row.ParameterName -ne [DbNull]::Value) -and ($row.ParameterValue.ToString() -ne [DbNull]::Value))
    {
        if(!([String]::IsNullOrEmpty($row.ParameterName)) -and !([String]::IsNullOrEmpty($row.ParameterValue)))
        {   #write-host "paraName: "$row.ParameterName"ParaValue: "$row.ParameterValue
            $argList+="-setParam=Name='"+$($row.ParameterName.ToString())+"',value='"+$($row.ParameterValue.ToString()) + "' "
        }
    }
}
$argList+="-setParam=Name='IIS Web Application Name',value='$($row.'IIS Web Application Name'.ToString())'"
if($argList.Contains("F:\inetpub\logs")){$argList=$argList.replace("F:\inetpub\logs", "F:\inetpub\logs\$($ds.Tables[0].rows[0].IISPortNumber.ToString())")}
[String]$strChangeSet=(Get-ChildItem -Path ENV:BUILD_BuildNumber).value.toString()
if (((Get-ChildItem -Path Env:IsSimulated).Value.ToString() -like "false") -and (!($rows[0].TargetServer.Contains("ESCB")))){
write-host "Entering Remote PowerShell Part"
Invoke-Command -SessionOption (New-PSSessionOption -IncludePortInSPN) -ComputerName $($row.TargetServer.ToString()) -Authentication Kerberos `
              -ScriptBlock {If (!(Test-Path -Path F:\Backup\WebApp)){New-Item -Path F:\Backup\WebApp -ItemType directory};`								
	                           Add-Type -assembly "system.io.compression.filesystem";`
                               Get-ChildItem -Path "F:\Backup\WebApp\" | `
                               Where-Object -FilterScript {$_.CreationTime -lt ((Get-Date).AddDays(-12))} | `
                               Remove-Item -Recurse -Confirm:$false -Force;`
	                           Get-ChildItem -Path F:\*$($using:strEnv)* -Directory |`
	                           ForEach-Object -Process {[io.compression.zipfile]::CreateFromDirectory((($PsItem.FullName.ToString())+"\"), ("F:\Backup\WebApp\WebAppDeployment-"+$($using:strChangeSet)+"-"+$PsItem.Name.ToString()+".zip"))}
                            }
}
write-host "Commence deployment Project Name 2.0"
$regex = New-Object System.Text.RegularExpressions.Regex ("[A-Z]{1}:\\(\w{0,255}\\)*\w{0,255}[.][a-zA-Z0-9]{3}")
[System.Text.RegularExpressions.Match]$match=$regex.Match($argList)
while ($match.Success)
{
    [System.Text.RegularExpressions.CaptureCollection]$cc=([System.Text.RegularExpressions.Group]$match.Groups.Item(0)).Captures
    foreach ($item in $cc){#Write-Host "Pos. "$item.index" Length of Match: "$item.Length"End of Match: "$($item.Index+$item.Length)" ->Resulting String: "$argList.Substring($item.Index,$item.Length)
        $strArray=$ArgList.Substring($item.Index,$item.Length).Split("\")
        if ($strArray.Count -gt 1){
            if ([System.Int16]::TryParse($strArray[($strArray.Count-2)],[ref]$int))
            {
                if ([System.Int16]::Parse($strArray[($strArray.Count-2)].Trim()) -ne [System.Int16]::Parse($ds.Tables[0].rows[0].IISPortNumber))
                {
                    $strArray[($strArray.Count-2)]=$ds.Tables[0].rows[0].IISPortNumber.ToString()
                }
            }
            else
            {
                $strArray[($strArray.Count-2)]+="\"+$ds.Tables[0].rows[0].IISPortNumber.ToString()
            }
        }#;Write-Host "JOINED: "([System.String]::Join("\",$strArray))
        $argList=$argList.Replace(($ArgList.Substring($item.Index,$item.Length)),([System.String]::Join("\",$strArray)))
    }
    $match=$match.nextMatch()
}
write-host "ArgList 2x: "$argList
Start-Process -FilePath $((Get-ChildItem -Path Env:MsDeployPath).Value.toString()) -ArgumentList $argList.TrimEnd() -NoNewWindow -wait
write-host "Deployment completed for Project Name 2.0"
if ($ds.Tables[0].Select("ParameterName LIKE 'DropZone%'").Count -lt 1){throw "No DropZone Parameter in Pilot ResultSet";exit 99}
$argList=$arglist.Replace($($ds.Tables[0].Select("ParameterName LIKE 'DropZone%'")[0].ParameterValue.ToString()),"{Placeholder}")
$argList=$argList.Substring(0,($argList.IndexOf("-verbose")+8)).trim()+" " #Start open query for Pilot
$strSQL="SELECT ALL * FROM [UDFRetrieveBasicDeployString]('$((Get-ChildItem -Path Env:AppTypePilot).Value.ToString())','$strEnv')"
$da.Dispose();$da=New-Object SqlClient.SqlDataAdapter((New-Object SqlClient.SqlCommand($strSQL,$con)))
if ($con.State -eq [System.Data.ConnectionState]'Closed'){$con.Open()}
$ds.Tables.Clear();$da.Fill($ds)
if ($ds -eq $null){throw "DataSet was null"}
if ($ds.Tables.Count -lt 1){throw "SQL Query returned no tables";exit 99}
if ($ds.Tables[0].Rows.Count -lt 1){throw "SQL Query returned no rows"}
if ($con.State -ne [System.Data.ConnectionState]'Closed'){$con.Close()}
ForEach ($row In $ds.Tables[0].Select("ParameterName NOT LIKE 'DropZone%'"))
{
    if (($row.ParameterName -ne [DbNull]::Value) -and ($row.ParameterValue.ToString() -ne [DbNull]::Value))
    {
        if(!([String]::IsNullOrEmpty($row.ParameterName)) -and !([String]::IsNullOrEmpty($row.ParameterValue)))
        {   #write-host "paraName: "$row.ParameterName"ParaValue: "$row.ParameterValue
            $argList+="-setParam=Name='"+$($row.ParameterName.ToString())+"',value='"+$($row.ParameterValue.ToString()) + "' "
        }
    }
}
$arglist=$argList.Replace("{Placeholder}",$ds.Tables[0].Select("ParameterName LIKE 'DropZone%'")[0].ParameterValue.ToString())
$argList+="-setParam=Name='IIS Web Application Name',value='$($row.'IIS Web Application Name'.ToString())\Pilot'"
$argList=$ArgList.replace("connectionString", "ConStringDef")
[System.Text.RegularExpressions.Match]$match=$regex.Match($argList)
while ($match.Success)
{
    [System.Text.RegularExpressions.CaptureCollection]$cc=([System.Text.RegularExpressions.Group]$match.Groups.Item(0)).Captures
    foreach ($item in $cc){#Write-Host "Pos. "$item.index" Length of Match: "$item.Length"End of Match: "$($item.Index+$item.Length)" ->Resulting String: "$argList.Substring($item.Index,$item.Length)
        $strArray=$ArgList.Substring($item.Index,$item.Length).Split("\")
        if ($strArray.Count -gt 1){
            if ([System.Int16]::TryParse($strArray[($strArray.Count-2)],[ref]$int))
            {
                if ([System.Int16]::Parse($strArray[($strArray.Count-2)].Trim()) -ne [System.Int16]::Parse($ds.Tables[0].rows[0].IISPortNumber))
                {
                    $strArray[($strArray.Count-2)]=$ds.Tables[0].rows[0].IISPortNumber.ToString()
                }
            }
            else
            {
                $strArray[($strArray.Count-2)]+="\"+$ds.Tables[0].rows[0].IISPortNumber.ToString()
            }
        }#Write-Host "JOINED: "([System.String]::Join("\",$strArray))
        $argList=$argList.Replace(($ArgList.Substring($item.Index,$item.Length)),([System.String]::Join("\",$strArray)))
    }
    $match=$match.nextMatch()
}
write-host "Commence deployment Project Name Pilot"
write-host "ArgList Pilot "$argList
Start-Process -FilePath $((Get-ChildItem -Path Env:MsDeployPath).Value.toString()) -ArgumentList $argList.TrimEnd() -NoNewWindow -wait
$con.Dispose();$ds.Dispose();$da.Dispose();write-host "********************Deployments completed*******************"