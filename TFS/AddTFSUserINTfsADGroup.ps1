#$release="2_7"
$tf="F:\Programs\VS2017\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tfssecurity.exe"
$release="${ENV:Release}"
Write-Host "Release name $release"
$count=$release.Split("_") | measure-object
if($count.count -eq 3)
{
echo "Branch Name contain 3 character"
$branch=$release.Split("_")
$Tfsbranch=$branch[0]+"."+$branch[1]+"."+$branch[2]
$Tfsbranch
}
else
{
echo "Branch Name contain 2 character"
$branch=$release.Split("_")
$Tfsbranch=$branch[0]+"."+$branch[1]
$Tfsbranch
}
$users=get-content "ShareFolderPath\$release.txt"
$TFSgroup="IMAS $Tfsbranch Developers"
$domain="ECBT1\"

foreach($user in $users)
{
$isMember = !(( &$tf /m $TFSgroup n:$domain$user /collection:"https:TFSURL/IMAS" ) -match "IS NOT" ) 
$isMember
if($isMember -match 'False')
{
write-host "User is not in group" -ForegroundColor Yellow
&$tf /g+ $TFSgroup n:$domain$user /collection:"https:TFSURL/IMAS"
}
else
{
write-host "$user is already in group" -ForegroundColor DarkGreen
}
}
