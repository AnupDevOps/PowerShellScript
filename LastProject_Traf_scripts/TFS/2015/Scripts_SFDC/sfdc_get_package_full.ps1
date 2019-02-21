#####################################################################################
#																				   	#
# Description: PowerShell Script to create incremental or full build in SalesForce 	#
#																				   	#
# Author:      Tushar Meshram														#
#																					#				
#####################################################################################

$scriptName = $MyInvocation.MyCommand.Name
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptPath = $PSScriptRoot
#$BldDrop="${Env:TF_BUILD_DROPLOCATION}"
#$tempDestLocation="$BldDrop\SFDC-TEMP-BUILD"
$srcFolder="${scriptPath}\..\src"
$packageXMLFile="${srcFolder}\package.xml"



$build_name=$env:BUILD_DEFINITIONNAME
$bnumber="${Env:BUILD_BUILDNUMBER}" 
$BldDrop="\\ttrafloco2k910\BINARIES\CRM\SFDC\master\$build_name\$bnumber"
$tempDestLocation="$BldDrop"


$sfun="$Env:sfUsername"
$sfpass="$Env:sfPassword"
$sfserurl="$Env:sfserverurl"


(Get-Content $scriptPath\build.properties) | Foreach { $_ -Replace "user\.", $sfun } | Set-Content $scriptPath\build.properties;
(Get-Content $scriptPath\build.properties) | Foreach { $_ -Replace "password\.", $sfpass } | Set-Content $scriptPath\build.properties;
(Get-Content $scriptPath\build.properties) | Foreach { $_ -Replace "url\.", $sfserurl } | Set-Content $scriptPath\build.properties;


echo "Folder location of src : ${srcFolder}"
echo "Temp Destination location : ${tempDestLocation}"
if(!(Test-Path -Path $tempDestLocation ))
	{
		echo "Directory $tempDestLocation does Not Exists"
		New-Item -ItemType directory -Force -Path "$tempDestLocation"
        echo "Created Directory $tempDestLocation"
	}
else 
	{	
		Remove-Item -Recurse -Force "$tempDestLocation/*"
	}

$packageXML=[xml]$(cat ${packageXMLFile})
$tagNamesArray=[array]$($packageXML.Package.Types.name)

if ($tagNamesArray.Length -eq 0) 
	{ 
		echo "Nothing to deploy as no components exists in package.xml"; 
		exit 1
	}

$uniqTagNamesArray=$($packageXML.Package.Types.name|select -uniq)

$fileCheckFlag="T"
foreach (${element} in ${uniqTagNamesArray})
{
	echo "Now processing component : ${element}"
	${tagNamePosition}=[array]($tagNamesArray|Select-String "^${element}$").LineNumber
	
	if (${tagNamePosition}.Length -gt 1)
		{ 
			echo "${element} occurence is $(${tagNamePosition}.Length) times in package.xml"
			echo "Exiting....."
			exit 1
		}
	else 
		{	
			${ValidDir}="true"
			$excludeArray=@()
			switch (${element})
			{
				ApexClass {$targerFldr="classes"; $extnArray = @("cls","cls-meta.xml")}
				ApexComponent {$targerFldr="components"; $extnArray = @("component","component-meta.xml")}
				ApexPage {$targerFldr="pages"; $extnArray = @("page","page-meta.xml")}
				ApexTrigger {$targerFldr="triggers"; $extnArray = @("trigger","trigger-meta.xml")}
				AppMenu {$targerFldr="appMenus"; $extnArray = @("appMenu")}
				ApprovalProcess {$targerFldr="approvalProcesses"; $extnArray = @("approvalProcess")}
				## Added AutoResponseRule
				AutoResponseRule {$targerFldr="objects"; $extnArray = @("object")}
				## Added AssignmentRule
				AssignmentRule {$targerFldr="assignmentRules"; $extnArray = @("assignmentRules")}
				## Added BusinessProcess
				BusinessProcess {$targerFldr="objects"; $extnArray = @("object")}
				Community {$targerFldr="communities"; $extnArray = @("community")}
				ConnectedApp {$targerFldr="connectedApps"; $extnArray = @("connectedApp")}
				CustomLabel {$targerFldr="labels"; $extnArray = @("labels")}
				CustomObject {$targerFldr="objects"; $extnArray = @("object")}
				CustomObjectTranslation {$targerFldr="objectTranslations"; $extnArray = @("objectTranslation")}
				## Added CustomField
				CustomField {$targerFldr="objects"; $extnArray = @("object")}
				CustomTab {$targerFldr="tabs"; $extnArray = @("tab")}
				CustomSite {$targerFldr="sites"; $extnArray = @("site")}
				CustomApplication {$targerFldr="applications"; $extnArray = @("applications")}
				CustomMetadata {$targerFldr="customMetadata"; $extnArray = @("md")}
				CustomPageWebLink {$targerFldr="weblinks"; $extnArray = @("weblink")}
				CustomPermission {$targerFldr="customPermissions"; $extnArray = @("customPermissions")}
				DataCategoryGroup {$targerFldr="datacategorygroups"; $extnArray = @("DataCategoryGroup")}
				Dashboard {$targerFldr="dashboards"; $extnArray = @("dashboard")}
				Document {$targerFldr="documents"; $extnArray = @("png","png-meta.xml"); $excludeArray=@('Communities_Shared_Document_Folder')}
				EmailTemplate {$targerFldr="email"; $extnArray = @("email","email-meta.xml"); $excludeArray=@('unfiled$public')}
				FieldSet {$targerFldr="objects"; $extnArray = @("object")}
				Flow {$targerFldr="flows"; $extnArray = @("flow")}
				Group {$targerFldr="groups"; $extnArray = @("group")}
				GlobalPicklist {$targerFldr="globalPicklists"; $extnArray = @("globalPicklist")}
				HomePageComponent {$targerFldr="homePageComponents"; $extnArray = @("flow")}
				HomePageLayout {$targerFldr="homePageLayouts"; $extnArray = @("homePageComponent")}
				Layout {$targerFldr="layouts"; $extnArray = @("layout")}
				Letterhead {$targerFldr="letterhead"; $extnArray = @("letter")}
				## Added ListView
				ListView {$targerFldr="objects"; $extnArray = @("object")}
				MilestoneType {$targerFldr="milestoneTypes"; $extnArray = @("milestoneTypes")}
				PermissionSet {$targerFldr="permissionsets"; $extnArray = @("permissionset")}
				Portal {$targerFldr="portals"; $extnArray = @("portal")} 
				Profile	{$targerFldr="profiles"; $extnArray = @("profile")}
				Queue {$targerFldr="queues"; $extnArray = @("queue")}
				QuickAction	{$targerFldr="quickActions"; $extnArray = @("quickAction")}
				Report {$targerFldr="reports"; $extnArray = @("report"); $excludeArray=@('unfiled$public')}
				Reporttype	{$targerFldr="reportTypes"; $extnArray = @("reportType")}
				RemoteSiteSetting {$targerFldr="remoteSiteSettings"; $extnArray = @("remoteSite")}
				Role {$targerFldr="roles"; $extnArray = @("role")}
				SharingCriteriaRule {$targerFldr="sharingRules"; $extnArray = @("sharingRules")}
				SharingRule {$targerFldr="sharingRules"; $extnArray = @("sharingRules")}
				SharingOwnerRule {$targerFldr="sharingRules"; $extnArray = @("sharingRules")}
				SharingTerritoryRule {$targerFldr="sharingRules"; $extnArray = @("sharingRules")}
				Settings {$targerFldr="settings"; $extnArray = @("settings")}
				SiteDotCom {$targerFldr="siteDotComSites"; $extnArray = @("site","site-meta.xml")}
				StaticResource {$targerFldr="staticresources"; $extnArray = @("resource","resource-meta.xml")}
				WebLink {$targerFldr="weblinks"; $extnArray = @("weblink")}
				Workflow {$targerFldr="workflows"; $extnArray = @("workflow")}
				## Added WorkflowFieldUpdate
				WorkflowFieldUpdate {$targerFldr="workflows"; $extnArray = @("workflow")}
				## WorkflowRule
				WorkflowRule {$targerFldr="workflows"; $extnArray = @("workflow")}
				WorkflowAlert {$targerFldr="workflows"; $extnArray = @("workflow")}
				
				### CRM 
				FlowDefinition {$targerFldr="flowDefinitions"; $extnArray = @("flowDefinition")}
				ApexTestSuite {$targerFldr="testSuites"; $extnArray = @("testSuite")}
				GlobalValueSet {$targerFldr="globalValueSets"; $extnArray = @("globalValueSet")}
				LeadConvertSettings {$targerFldr="LeadConvertSettings"; $extnArray = @("LeadConvertSetting")}
				Translations {$targerFldr="translations"; $extnArray = @("translation")}
				RecordType {$targerFldr="objects"; $extnArray = @("object")}
				ValidationRule {$targerFldr="objects"; $extnArray = @("object")}
				StandardValueSet {$targerFldr="standardValueSets"; $extnArray = @("standardValueSet")}
				FlexiPage {$targerFldr="flexipages"; $extnArray = @("flexipage")}
				DelegateGroup {$targerFldr="delegateGroups"; $extnArray = @("delegateGroup")}
				DuplicateRule {$targerFldr="duplicateRules"; $extnArray = @("duplicateRule")}
				EscalationRules {$targerFldr="escalationRules"; $extnArray = @("escalationRules")}
				MatchingRule {$targerFldr="matchingRules"; $extnArray = @("matchingRule")}
				CompactLayout {$targerFldr="layouts"; $extnArray = @("layout")}
				CallCenter {$targerFldr="callCenters"; $extnArray = @("callCenter")}
				default {${ValidDir}="false"}
			}
			
			if (${ValidDir} -eq "false") {echo "Not a valid element : ${element} to process"; exit 1}
			
			echo "${element} occurence is $(${tagNamePosition}.Length) time in package.xml"
			$indx=$tagNamesArray.IndexOf(${element})
			$memberList=[array]$packageXML.Package.types[$indx].members
			
			echo "Checking for * in memberList"
			echo "MEMBER LIST is $memberList"

## <member_name>.extnArray ##
			
			if (${element} -eq "ApexClass" -or ${element} -eq "ApexComponent" -or ${element} -eq "ApexPage"  -or ${element} -eq "ApexTrigger" -or ${element} -eq "ApexTrigger"  -or ${element} -eq "CustomApplication" -or ${element} -eq "customMetadata" -or ${element} -eq "DataCategoryGroup" -or ${element} -eq "Group" -or ${element} -eq "RemoteSiteSetting" -or ${element} -eq "ReportType" -or ${element} -eq "CustomPermission" -or ${element} -eq "GlobalPicklist" -or ${element} -eq "MilestoneType" -or ${element} -eq "SharingCriteriaRule" -or ${element} -eq "SharingOwnerRule" -or ${element} -eq "SharingTerritoryRule" -or ${element} -eq "CustomLabel"  -or ${element} -eq "FlowDefinition" -or ${element} -eq "GlobalValueSet" -or ${element} -eq "LeadConvertSettings" -or ${element} -eq "LeadConvertSettings" -or ${element} -eq "ValidationRule" -or ${element} -eq "Role" -or ${element} -eq "Profile" -or ${element} -eq "CustomObject" -or ${element} -eq "Translations" -or ${element} -eq "Flow" -or ${element} -eq "PermissionSet" -or ${element} -eq "Layout" -or ${element} -eq "AppMenu" -or ${element} -eq "Community" -or ${element} -eq "HomePageComponent"  -or ${element} -eq "HomePageLayout" -or ${element} -eq "Letterhead" -or ${element} -eq  "Portal" -or ${element} -eq "Queue" -or ${element} -eq "QuickAction" -or ${element} -eq "StaticResource" -or ${element} -eq "Workflow" -or ${element} -eq "Settings" -or ${element} -eq "FlexiPage" -or ${element} -eq "CustomObjectTranslation" -or ${element} -eq "CustomTab" -or ${element} -eq  "ApexTestSuite"  -or ${element} -eq  "delegateGroup" -or ${element} -eq "CompactLayout"  -or ${element} -eq  "CallCenter"  -or ${element} -eq  "SharingRule")  
				{ 	
					echo "${element} contains * in its member list"
					echo "Copying ${targerFldr} folder recursively into ${tempDestLocation}  " 
					Copy-Item ${srcFolder}\${targerFldr} ${tempDestLocation} -recurse -Force
					echo "`n`n"
				}
			else 
				{ 
					echo "------MEMBER LIST--------"
					$memberList
					echo "------MEMBER LIST-------`n"
		## <member_name>.extnArray with file name##
					if (${element} -eq "Document" )
						{
							New-Item -ItemType Directory -Force -Path "$tempDestLocation\${targerFldr}"
							foreach (${member} in ${memberList})
							{
							
								if ($(${member} | select-string "\/")) 
									{ 
										echo "File : ${member}"
										foreach (${fileExtn} in ${extnArray})
												{													
													$dirPath=split-path "${member}.${fileExtn}"
													if(!(Test-Path -Path "$tempDestLocation\${targerFldr}\$dirPath" -PathType Container))
														{
															New-Item -ItemType Directory -Force -Path "$tempDestLocation\${targerFldr}\$dirPath"
														}
																											
													if (Test-Path -Path "${srcFolder}\${targerFldr}\${member}" -PathType Leaf)
														{
															Copy-Item -Path "${srcFolder}\${targerFldr}\*" "${tempDestLocation}\${targerFldr}\" -recurse -Force
														}
													else 
														{
															echo "File not available : ${srcFolder}\${targerFldr}\${member}.${fileExtn}"
															$fileCheckFlag="F"
														}														
												}										
									}
						}
					}
		## <member_name>.extnArray with folders in it ##
					if (${element} -eq "Dashboard" -or ${element} -eq "Report" -or ${element} -eq "EmailTemplate") 
						{
							New-Item -ItemType Directory -Force -Path "$tempDestLocation\${targerFldr}"
							foreach (${member} in ${memberList})
							{
#								
								if ($(${member} | select-string "\/")) 
									{ 
										echo "File : ${member}"
										foreach (${fileExtn} in ${extnArray})
												{													
													$dirPath=split-path "${member}.${fileExtn}"
													if(!(Test-Path -Path "$tempDestLocation\${targerFldr}\$dirPath" -PathType Container))
														{
															New-Item -ItemType Directory -Force -Path "$tempDestLocation\${targerFldr}\$dirPath"
														}
													
														
													if (Test-Path -Path "${srcFolder}\${targerFldr}\${member}.${fileExtn}" -PathType Leaf)
														{
															Copy-Item -Path "${srcFolder}\${targerFldr}\${member}.${fileExtn}" "${tempDestLocation}\${targerFldr}\${dirPath}" -recurse -Force
														}
													else 
														{
															echo "File not available : ${srcFolder}\${targerFldr}\${member}.${fileExtn}"
															$fileCheckFlag="F"
														}														
												}										
									}
								elseif ($excludeArray -contains ${member})
									{
										echo "Skipping : ${member}"								
									}
									
								else
									{
										if(!(Test-Path -Path "$tempDestLocation\${targerFldr}\${member}" -PathType Container))
											{
												New-Item -ItemType Directory -Force -Path "$tempDestLocation\${targerFldr}\${member}"
											}
											
										if (Test-Path -Path "${srcFolder}\${targerFldr}\${member}-meta.xml" -PathType Leaf)
											{
												Copy-Item -Path "${srcFolder}\${targerFldr}\${member}-meta.xml" "${tempDestLocation}\${targerFldr}" -recurse -Force										
											}
										else {
												echo "File not available : ${srcFolder}\${targerFldr}\${member}-meta.xml"
												$fileCheckFlag="F"
											 }											 
									}									
							}
						}
		## <member_name>.extnArray Account.workflow ##
			if (${element} -eq "AssignmentRule" -or ${element} -eq "CustomField" -or ${element} -eq "ListView" -or ${element} -eq "AutoResponseRule"  -or ${element} -eq "BusinessProcess" -or ${element} -eq "WorkflowFieldUpdate" -or ${element} -eq "WorkflowRule" -or ${element} -eq "WorkflowAlert"  -or ${element} -eq "standardValueSet" -or ${element} -eq "RecordType"  -or ${element} -eq  "DuplicateRule"  -or ${element} -eq  "EscalationRules" -or ${element} -eq "MatchingRule") 
						{
							echo " I am in"
							echo "MEMEBER is $member"
							New-Item -ItemType Directory -Force -Path "$tempDestLocation\${targerFldr}"
							foreach (${member} in ${memberList})
							{
								echo "MEMEBER is $member"
								$var=$member
								$first,$second=$var.Split('.',2)
								
								foreach (${fileExtn} in ${extnArray})
									{
										$dirPath=split-path "${first}.${fileExtn}"
													if(!(Test-Path -Path "$tempDestLocation\${targerFldr}\$dirPath" -PathType Container))
														{
															New-Item -ItemType Directory -Force -Path "$tempDestLocation\${targerFldr}\$dirPath"
														}
														
													if (Test-Path -Path "${srcFolder}\${targerFldr}\${first}.${fileExtn}" -PathType Leaf)
														{
															Copy-Item -Path "${srcFolder}\${targerFldr}\${first}.${fileExtn}" "${tempDestLocation}\${targerFldr}\${dirPath}" -recurse -Force
															echo "Flag is  $fileCheckFlag"
														}
													else 
														{
															echo "File not available : ${srcFolder}\${targerFldr}\${first}.${fileExtn}"
															$fileCheckFlag="F"
														}														
									}										
								}
						}
									
					echo "`n`n"	
				}
		}	
}

if ($fileCheckFlag -eq "F")
	{
		echo "Build Failed due to required files not available in src location"
		exit 1
	}
else 
	{
		
		echo "Required Build files are copied successfully from src location to $tempDestLocation"
		###Copying build.xml located in Scripts folder to ${tempDestLocation}\..
		Copy-Item -Path "${scriptPath}\build.xml" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${packageXMLFile}" "${tempDestLocation}" -recurse -Force
		Copy-Item -Path "${scriptPath}\sfdc_deploy.ps1" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${scriptPath}\build.properties" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${scriptPath}\sfdc_deployCodeCheck.ps1" "${BldDrop}" -recurse -Force
		Copy-Item -Path "${scriptPath}\get_buildProperties.ps1" "${BldDrop}" -recurse -Force
	}