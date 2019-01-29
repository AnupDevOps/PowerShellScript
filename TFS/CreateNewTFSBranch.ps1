$source="${ENV:source}"
$target="${ENV:target}"
$tf="F:\Programs\VS2017\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"
$release="$Env:Build_SourcesDirectory"
cd $release\IMAS2\Releases\R_2_10_0\R_2_10_0_DEV
&$tf branch $/Development/IMAS2/Releases/R_2_10_0/R_$source $/Development/IMAS2/Releases/R_2_10_0/STABLE/R_$target
&$tf checkin /comment:"New Branch is Created" /override:"Automerge Changes"