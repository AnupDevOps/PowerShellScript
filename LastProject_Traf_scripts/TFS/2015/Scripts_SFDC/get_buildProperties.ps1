#script to create buil.properties


$build_name=$env:BUILD_DEFINITIONNAME
$bnumber="${Env:BUILD_BUILDNUMBER}" 
$build_path= "\\ttrafloco2k910\BINARIES\CRM\SFDC\master\$build_name\$bnumber"



$username=Select-String -Path $build_path\build.properties "sf.username"
$password=Select-String -Path $build_path\build.properties "sf.password"
$username = $username -replace(' ','')
$password = $password -replace(' ','')

$name=$username.split("=")
$pass=$password.split("=")



$sfun="$Env:sfUsername"
$sfpass="$Env:sfPassword"




(Get-Content $build_path\build.properties) | Foreach { $_ -Replace $name[1], $sfun } | Set-Content $build_path\build.properties;
(Get-Content $build_path\build.properties) | Foreach { $_ -Replace $pass[1], $sfpass } | Set-Content $build_path\build.properties;
