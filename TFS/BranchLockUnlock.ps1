################################################################################################################################################################################
##############################################                    PowerShell Script to Lock and Unlock Branch                    ###############################################
################################################################################################################################################################################


$TF = "F:\Programs\VS2017\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"
#$action= "lock"
$action="${ENV:Action}"
$branch="${ENV:Branch}"
$b1="$/Development/IMAS2/Releases/R_$branch/R_"
$b3="_DEV"
$fullBranch = $b1+$branch+$b3 
if ($action -ieq "LOCK")
{
   &$TF lock /lock:checkin $fullBranch
	echo "Branch $branch is Locked now"
}
elseif ($action -ieq "Unlock")
{
	# &$TF undo $fullBranch /recursive
	echo "Branch $branch is unlocked now"
}
else
{
	echo "You Entered the wronge Action, Action can Either Lock or Unlock"
}
