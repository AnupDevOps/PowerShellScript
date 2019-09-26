#######################################################################################################
###############                 Compare two Folders if they are on Same servers          ##############
#######################################################################################################


# User varaibles
$SourceFolderpath="D:\Work\PowerShell_Scripts"
$TargetFolderpath="D:\Work\PowerShell_Scripts - Copy"
$LogFolderpath="D:\Log"


#$fso = Get-ChildItem -Recurse -path $SourceFolderpath -Name
#$fsoBU = Get-ChildItem -Recurse -path $TargetFolderpath -Name
#Compare-Object -ReferenceObject $fso -DifferenceObject $fsoBU



###############################################################################
### Compare two Folders if they are on Different servers 
###############################################################################
If(!(Test-Path -path $LogFolderpath))
    {
        write-host "Creating Log Folder......." -ForegroundColor DarkGreen
        New-Item -Path $LogFolderpath -ItemType directory
        Get-ChildItem -Recurse -path $SourceFolderpath -Name > $LogFolderpath\File1.txt
        Get-ChildItem -Recurse -path $TargetFolderpath -Name > $LogFolderpath\File2.txt
        $fso=Get-Content $LogFolderpath\File1.txt

        $fsoBU=Get-Content $LogFolderpath\File2.txt
        Compare-Object -ReferenceObject $fso -DifferenceObject $fsoBU
        
    }
else
    {
        write-host "Log Folder is there" -ForegroundColor DarkGreen
        Get-ChildItem -Recurse -path $SourceFolderpath -Name > $LogFolderpath\File1.txt
        Get-ChildItem -Recurse -path $TargetFolderpath -Name > $LogFolderpath\File2.txt
        $fso=Get-Content $LogFolderpath\File1.txt

        $fsoBU=Get-Content $LogFolderpath\File2.txt
        Compare-Object -ReferenceObject $fso -DifferenceObject $fsoBU
        
    }

remove-item $LogFolderpath -Recurse
#Compare-Object -ReferenceObject (Get-Content D:\DB\File1.txt) -DifferenceObject (Get-Content D:\DB\File2.txt)