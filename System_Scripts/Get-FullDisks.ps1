#Get VMs
$Project1VMs = Get-ADComputer -Filter * -SearchBase "OU=IMAS,OU=Services,OU=,DC=,DC=tadnet,DC=net" | Where-Object -FilterScript {($PSItem.Name -notlike "*IMAS-AG*") -and ($PSItem.Name -notlike "*CAS*")}
$ProjectVMs = Get-ADComputer -Filter * -SearchBase "OU=IMAS,OU=Services,OU=,DC=,DC=eu" -Server edcws01.escb.eu | Where-Object -FilterScript {($PSItem.Name -notlike "*Cluster*") -and ($PSItem.Name -notlike "*CLR*") -and ($PSItem.Name -notlike "*IMAS-AG*")}

#Prepare Table
[String]$Mail = "<p>"
$Mail += "<b><u>TADNET Disk Usage</u></b>"
$Mail += "</p>"
$Mail +="<table border=`"1`"><tr><td><b>Drive</b></td><td><b>Server</b></td><td><b>Purpose</b></td><td><b>Free Space</b></td></tr>"

#Get  Disks
$Project1VMs | ForEach-Object {
    $ServerName = $PSItem.name
    $Purpose = $PSItem.DistinguishedName.split(",OU=")[5]
    $Domain = ""
    Try
    {
        If ((Test-NetConnection -ComputerName $ServerName).PingSucceeded)
        {
            if((Get-ADComputer -Identity $ServerName -Properties ServicePrincipalName | Select-Object -ExpandProperty ServicePrincipalName | `
            Where-Object -FilterScript {$PsItem.StartsWith("HTTP")} | Measure-Object | Select-Object -ExpandProperty Count) -gt 0)
            {
                [Microsoft.Management.Infrastructure.CimSession]$cs=New-CimSession -Authentication Kerberos `
                    -ComputerName ($ServerName+"."+((Get-CimInstance -ClassName Win32_ComputerSystem -Property Domain | Select-Object -Property Domain).domain)) `
                    -SessionOption (New-CimSessionOption -EncodePortInServicePrincipalName)
                [System.Array]$Disk = Get-CimInstance -CimSession $cs -ClassName win32_logicaldisk -Filter "Drivetype=3" -ErrorAction Stop
            }
            else
            {
                [System.Array]$Disk = Get-CimInstance -ClassName win32_logicaldisk -Filter "Drivetype=3" -ErrorAction Stop -ComputerName $ServerName
            }
            $Disk | Sort-Object FreeSpace | Format-Table SystemName, DeviceID, VolumeName, `
                @{Label="Total Size";Expression={$PSItem.Size / 1gb -as [int] }}, `
                    @{Label="Free Size";Expression={$PSItem.FreeSpace / 1gb -as [int] }}, `
                        @{Label="% Used";Expression={(100 / $PSItem.Size * ($PSItem.Size - $PSItem.FreeSpace)) -as [int] }} -autosize
            $Disk | Sort-Object FreeSpace | ForEach-Object {
                If (((($PSItem.FreeSpace / 1gb -as [int]) -lt 5) -or (((100 / $PSItem.Size * ($PSItem.Size - $PSItem.FreeSpace)) -as [int]) -gt 90)) -and ($PSItem.DeviceID -notlike "*D*") -and (($PSItem.Size / 1gb -as [int]) -gt 6))
                {$Mail += [String]("<tr><td>" + $PSItem.DeviceID + "</td><td>" + $ServerName + ".ecbt1.tadnet.net</td><td>" + $Purpose + "</td><td>" + ($PSItem.FreeSpace / 1gb -as [int]) + " GB</td></tr>")}
            }
        }
    }Catch{Write-Output "Could not get WMI information from $($ServerName): $($PSItem.Exception.Message)"; $Mail += [String]("<tr><td>" + $Domain + "</td><td>" + $ServerName + "</td><td>" + $Purpose + "</td><td>" + $($PSItem.Exception.Message) + "</td></tr>")}
} | Tee-Object "\\Shared-Folder-path\Scripts\TADNET-Monitoring\LogECBT1.txt"