cls
$listFilesInFolders = New-Object System.Collections.ArrayList
$filesInFolders = (Get-ChildItem *.cs -Recurse | Where-Object {$_.Name -notmatch ".*TemporaryGeneratedFile.*"} | Where-Object {$_.FullName -notmatch ".*\\Fakes\\.*"})
foreach ($file in $filesInFolders)
{
  [void] $listFilesInFolders.Add($file.FullName)
}


$filesInProjects = New-Object System.Collections.ArrayList
$projectsInFolders = Get-ChildItem *.csproj -Recurse | Where-Object {$_.Name -ne "f.csproj"}
foreach ($file in $projectsInFolders)
{
  $basePath = ($file.PSParentPath -split "::")[1]
  $content = Get-Content $file 
  $lines =   $content -match "<Compile Include=" 

  foreach ($line in $lines)
  {
    [void] $filesInProjects.Add($basePath + "\" + ($line -split """")[1])
  }
}


$except = $listFilesInFolders | ?{$filesInProjects -notcontains $_} 
$except >> DeadFiles_after.txt
$except.Count 


$modulename=Select-String DeadFiles.txt -Pattern "modulename" 
echo "modulename Files"
$modulename

$modulename2=Select-String DeadFiles.txt -Pattern "modulename2" 
echo "modulename2 Files"
$modulename2
