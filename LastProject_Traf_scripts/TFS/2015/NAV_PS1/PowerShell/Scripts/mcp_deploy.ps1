$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot
$CompanyName = "AAF"
$build_number="${Env:BUILD_BUILDNUMBER}"
$build_name="${Env:BUILD_DEFINITIONNAME}"
$baseloc="C:\$build_name"
$ConfigPath = "C:\$build_name\Master_Config_Package\"

$mcpenvfolder="$baseloc\Master_Config_Package\Environment"

$envs = $(Get-Content "$baseloc\env_names.txt")

Import-Module "${env:ProgramFiles}\Microsoft Dynamics NAV\80\Service\NavAdminTool.ps1" -force
Import-Module "${env:ProgramFiles(x86)}\Microsoft Dynamics NAV\80\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1" -force

foreach ($env in $envs)
	{
		write-host "Running for Global $env"
		Invoke-NAVCodeunit -ServerInstance $env -CodeunitId 85007 -CompanyName $CompanyName -MethodName ExecuteDailyDeployment -Argument $ConfigPath
	}


if (  Test-Path -Path $mcpenvfolder )
   {
		
		cd $baseloc\Master_Config_Package\Environment
		Get-ChildItem -dir -Name > $baseloc\env.txt 
	

		$environment= $(Get-Content "$baseloc\env.txt")
		foreach ($env in $environment)
			{
				
				write-host "Running for Environment $env"
				Invoke-NAVCodeunit -ServerInstance $env -CodeunitId 85007 -CompanyName $CompanyName -MethodName ExecuteDailyDeployment -Argument $ConfigPath
			}

   }