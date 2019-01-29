# run script in a folder that is mapped to a workspace

$TF = "F:\Programs\VS2017\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"

cls
Write-Output ""
Write-Output ""
Write-Output " #-------- Merge Backlog --------------- "
Write-Output ""

$a = &$TF Merge /candidate $/Development/IMAS2/Main $/Development/IMAS2/Releases/R_2_7/ /recursive 
Write-Output ("[ Main -->  2.7 ] : (" + $a.length + ")") 

$b = &$TF Merge /candidate $/Development/IMAS2/Releases//R_2_7_DEV $/Development/IMAS2/Releases/R_2_7_1/R_2_7_1_DEV /recursive 
Write-Output ("[ 2.7 -->  2.7.1 ] : (" + $b.length + ")")

$c = &$TF Merge /candidate $/Development/IMAS2/Releases//R_2_7_1_DEV $/Development/IMAS2/Releases//R_2_8_DEV /recursive 
Write-Output ("[ 2.7.1 -->  2.8 ] : (" + $c.length + ")") 

Write-Output ""
Write-Output ""
Write-Output " #--------Detail--------------- "
Write-Output ""

Write-Output ("[ Main -->  2.7 ] : (" + $a.length + ")")
Write-Output $a
Write-Output ""

Write-Output ("[ 2.7 -->  2.7.1 ] : (" + $b.length + ")")
Write-Output $b
Write-Output ""

Write-Output ("[ 2.7.1 -->  2.8 ] : (" + $c.length + ")")
Write-Output $c
