cls

$release="2.10"

$tfssecurity="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TFSSecurity.exe"

$Devgroup="IMAS"+" "+ $release + " "+ "Developers"

#Command to create new Developers TFS group
&$tfssecurity /gc "vstfs:///Classification/TeamProject/10a81d4d-fbd8-4f2d-ae61-f61df9fe2cb9" $Devgroup  /collection:"TFS-Collection-URL"

$HotFixgroup="IMAS"+" "+ $release + " "+ "HOTFIX Developers"
&$tfssecurity /gc "vstfs:///Classification/TeamProject/10a81d4d-fbd8-4f2d-ae61-f61df9fe2cb9" $HotFixgroup  /collection:"TFS-Collection-URL"


$releasegroup="IMAS"+" "+ $release + " "+ "Release Managers"
&$tfssecurity /gc "vstfs:///Classification/TeamProject/10a81d4d-fbd8-4f2d-ae61-f61df9fe2cb9" $releasegroup  /collection:"TFS-Collection-URL"
