#cls
$file = ""
$content = Get-Content $file

$pattern = "\\\\(File-Starting.[^\\]*?.csproj)"

$csprojfilename=([Regex]::Matches( $content , $pattern)).value.Substring(2) | Get-Unique


####################################################################################################################
# Logic to modified csproj files #

$currentRelease = "2_6"
$version = "2.6.0.0"
$currentModule = "Module_Name"

$pattern = "(' ')*?<ProjectReference.*?`r`n.*?`r`n.*?<Name>(Ecb.Imas.(Business|Data|Presentation).[^$currentModule].*?)</Name>.*?`r`n.*?</ProjectReference>"
$replacement = "`r`n<Reference Include=""`$2, Version=$version, Culture=neutral, processorArchitecture=MSIL"">`r`n <SpecificVersion>False</SpecificVersion>`r`n <HintPath>\\d-imas-fs.tadnet.net\DropZone\Release\R_$currentRelease\references\`$2.dll</HintPath>`r`n</Reference>"

foreach($path in $csprojfilename)
{
$paths=Get-ChildItem F:\Dev_new\Sln -Filter "$path" -Recurse | % { $_.FullName }

$file = $paths | Select-Object -first 1
$outfile = $file

$content = [System.IO.File]::ReadAllText($file)

$modified = [Regex]::Replace( $content , $pattern, $replacement )

#$modified

$encoding = New-Object System.Text.UTF8encoding
[System.IO.File]::WriteAllText($outfile, $modified, $encoding)
}
