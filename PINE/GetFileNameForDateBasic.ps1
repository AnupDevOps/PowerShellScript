$startdate=‘5/1/19’
$enddate=‘06/14/19’
get-childitem “D:\Work” -recurse |  ? {$_.lastwritetime -gt $startdate -AND $_.lastwritetime -lt $enddate}