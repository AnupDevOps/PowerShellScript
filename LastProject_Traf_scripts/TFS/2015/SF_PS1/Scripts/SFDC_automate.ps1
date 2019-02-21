$workspace="C:\GITSFDC"
cd $workspace
git checkout QA
git pull 

$envfolder="\\DPUMALON2K74\E-Puma Build\Defect Fixes SFDC\Fixes To Deploy"
cd $envfolder
$defect=Get-ChildItem -Path .\QA |   get-unique

if ($defect.Attributes -eq "Directory")
      {
            $defectfolder= $defect.Name
      } 
$src="$envfolder\QA\$defectfolder"
$defectID=$defectfolder.split("_")
$defectIDcomment=$defectID[1]
$checkincomments="Check-in for #$defectIDcomment"
############################################################################################################################
################################### SFDC Package creation ##################################################################
############################################################################################################################
$object_folder= Get-ChildItem  $src  -Name -attributes D -Recurse 
$object_folder > $src\List.txt
$xmlWriter = New-Object System.XMl.XmlTextWriter("$src\package.xml",$Null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Indentation = 1
$XmlWriter.IndentChar = "`t"
$xmlWriter.WriteStartDocument()
$xmlWriter.WriteStartElement('Package')
foreach ($object_folder_file in get-content $src\List.txt)
	{
	if($object_folder_file -eq "applications" )
		{
			cd $src
			
		
			Split-Path -Path "$object_folder_file\*.app" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement('types')
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						}
						## To Checkin ##
			
			$xmlWriter.WriteElementString('name',"CustomApplication")
			$xmlWriter.WriteEndElement()
		}
		
		if($object_folder_file -eq "assignmentRules" )
		{
			cd $src
			
		
			Split-Path -Path "$object_folder_file\*.assignmentRules" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement('types')
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						}
						
			$xmlWriter.WriteElementString('name',"AssignmentRule")
			$xmlWriter.WriteEndElement()
		}

		if($object_folder_file -eq "autoResponseRules" )
		{
			cd $src
			
		
			Split-Path -Path "$object_folder_file\*.autoResponseRules" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement('types')
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						}
						
			$xmlWriter.WriteElementString('name',"AutoResponseRule")
			$xmlWriter.WriteEndElement()
		}

		if($object_folder_file -eq "datacategorygroups" )
		{
			cd $src
			
		
			Split-Path -Path "$object_folder_file\*.datacategorygroup" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement('types')
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						}
						
			$xmlWriter.WriteElementString('name',"DataCategoryGroup")
			$xmlWriter.WriteEndElement()
		}

		if($object_folder_file -eq "flows" )
		{
			cd $src
			
		
			Split-Path -Path "$object_folder_file\*.flow" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement('types')
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						}
						
			$xmlWriter.WriteElementString('name',"Flow")
			$xmlWriter.WriteEndElement()
		}
		if($object_folder_file -eq "homePageComponents" )
		{
			cd $src
			
		
			Split-Path -Path "$object_folder_file\*.homePageComponent" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement('types')
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						}
						
			$xmlWriter.WriteElementString('name',"HomePageComponent")
			$xmlWriter.WriteEndElement()
		}
		
	if($object_folder_file -eq "globalPicklists" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.globalPicklist" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"GlobalPicklist")
				$xmlWriter.WriteEndElement()
			}
				if($object_folder_file -eq "homePageLayouts" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.homePageLayout" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"homePageLayout")
				$xmlWriter.WriteEndElement()
			}
				if($object_folder_file -eq "letterhead" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.letter" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"letterhead")
				$xmlWriter.WriteEndElement()
			}
				if($object_folder_file -eq "objectTranslations" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.objectTranslation" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"CustomObjectTranslation")
				$xmlWriter.WriteEndElement()
			}
				if($object_folder_file -eq "permissionsets" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.permissionset" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"permissionset")
				$xmlWriter.WriteEndElement()
			}
				if($object_folder_file -eq "quickActions" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.quickAction" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"quickAction")
				$xmlWriter.WriteEndElement()
			}
			if($object_folder_file -eq "remoteSiteSettings" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.remoteSite" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"RemoteSiteSetting")
				$xmlWriter.WriteEndElement()
			}
			
			if($object_folder_file -eq "roles" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.role" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"Role")
				$xmlWriter.WriteEndElement()
			}
			if($object_folder_file -eq "weblinks" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.weblink" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"CustomPageWebLink")
				$xmlWriter.WriteEndElement()
			}
			if($object_folder_file -eq "workflows" )
				{
					cd $src
				
			
				Split-Path -Path "$object_folder_file\*.workflow" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
				$xmlWriter.WriteStartElement('types')
						foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
							{
								$file_name=$filename.split('.')[0]
								write-host "$file_name"
								$xmlWriter.WriteElementString('members',"$file_name")
							}
							
				$xmlWriter.WriteElementString('name',"workflow")
				$xmlWriter.WriteEndElement()
			}
			
		
	if($object_folder_file -eq "customMetadata" )
		{
			
			cd $src
			#$object_folder_file\*.md >> $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.md" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name_old2=$filename.split('.')[1]
							$file_name_old1=$filename.split('.')[0]
							$file_name="$file_name_old1.$file_name_old2"
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						}
						

			$xmlWriter.WriteElementString('name',"$object_folder_file")
			$xmlWriter.WriteEndElement()
		}
		if($object_folder_file -eq "classes" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.cls" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.cls-meta.xml" -Leaf -Resolve >> $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.cls" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy_pkg.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy_pkg.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			

			$xmlWriter.WriteElementString('name',"ApexClass")
			$xmlWriter.WriteEndElement()
		}

		if($object_folder_file -eq "components" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.component" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.component-meta.xml" -Leaf -Resolve >> $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.component" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy_pkg.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy_pkg.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			
			$xmlWriter.WriteElementString('name',"ApexComponent")
			$xmlWriter.WriteEndElement()
		}
			
		if($object_folder_file -eq "tabs" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.tab" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log

			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			

			$xmlWriter.WriteElementString('name',"CustomTab")
			$xmlWriter.WriteEndElement()
		}
		
		
if($object_folder_file -eq "triggers" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.trigger" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.trigger-meta.xml" -Leaf -Resolve >> $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.trigger" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy_pkg.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy_pkg.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			
			$xmlWriter.WriteElementString('name',"ApexTrigger")
			$xmlWriter.WriteEndElement()
		}
	
			if($object_folder_file -eq "reportTypes" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.reportType" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			

			$xmlWriter.WriteElementString('name',"ReportType")
			$xmlWriter.WriteEndElement()
		}
#################### Special case #########################		
		if($object_folder_file -eq "objects" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.object" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			
			$xmlWriter.WriteElementString('name',"CustomObject")
			$xmlWriter.WriteEndElement()
		}
###################################################################
	if($object_folder_file -eq "profiles" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.profile" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			

			$xmlWriter.WriteElementString('name',"Profile")
			$xmlWriter.WriteEndElement()
		}

		if($object_folder_file -eq "layouts" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.layout" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			## To Checkin ##
			

			$xmlWriter.WriteElementString('name',"Layout")
			$xmlWriter.WriteEndElement()
		}
		if($object_folder_file -eq "staticresources" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.resource" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.resource-meta.xml" -Leaf -Resolve >> $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.resource" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy_pkg.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy_pkg.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			## To Checkin ##
					
			$xmlWriter.WriteElementString('name',"StaticResource")
			$xmlWriter.WriteEndElement()
		}
		if($object_folder_file -eq "pages" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.page" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.page-meta.xml" -Leaf -Resolve >> $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\*.page" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy_pkg.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy_pkg.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
			## To Checkin ##
					
					

			$xmlWriter.WriteElementString('name',"ApexPage")
			$xmlWriter.WriteEndElement()
		}
		####################### Label special case ######################
	if($object_folder_file -eq "labels" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.labels" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
		## To Checkin ##
					

			$xmlWriter.WriteElementString('name',"CustomLabels")
			$xmlWriter.WriteEndElement()
		}
		
		if($object_folder_file -eq "ListView" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.objects" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
		

			$xmlWriter.WriteElementString('name',"ListView")
			$xmlWriter.WriteEndElement()
		}
		
			if($object_folder_file -eq "groups" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.group" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							#$file_name=$filename.split('.')[0]
							#write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$filename")
						
						}
		
			$xmlWriter.WriteElementString('name',"Group")
			$xmlWriter.WriteEndElement()
		}
		
			if($object_folder_file -eq "Queues" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.Queue" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
		

			$xmlWriter.WriteElementString('name',"Queue")
			$xmlWriter.WriteEndElement()
		}
		
			if($object_folder_file -eq "ApprovalProcesses" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.approvalProcess" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
		

			$xmlWriter.WriteElementString('name',"ApprovalProcess")
			$xmlWriter.WriteEndElement()
		}
		
			if($object_folder_file -eq "Workflows" )
		{
			
			cd $src
			Split-Path -Path "$object_folder_file\*.Workflow" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			$xmlWriter.WriteStartElement("types")
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$file_name")
						
						}
		

			$xmlWriter.WriteElementString('name',"Workflow")
			$xmlWriter.WriteEndElement()
		}
		
		
		
		if($object_folder_file -eq "email" )
		{
			$xmlWriter.WriteStartElement("types")
			$object_folder_inside= Get-ChildItem  $src\$object_folder_file  -Name -attributes D -Recurse > $src\$object_folder_file\folder_to_deploy.log
			foreach ($foldername in get-content $src\$object_folder_file\folder_to_deploy.log)
			{
			cd $src
			Split-Path -Path "$object_folder_file\$foldername\*.email" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$foldername\$file_name")
						
						}
		
			}
			
		
			$xmlWriter.WriteElementString('name',"EmailTemplate")
			$xmlWriter.WriteEndElement()
		}
		if($object_folder_file -eq "documents" )
		{
			$xmlWriter.WriteStartElement("types")
			$object_folder_inside= Get-ChildItem  $src\$object_folder_file  -Name -attributes D -Recurse > $src\$object_folder_file\folder_to_deploy.log
			foreach ($foldername in get-content $src\$object_folder_file\folder_to_deploy.log)
			{
			cd $src
			Split-Path -Path "$object_folder_file\*" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\$foldername\*" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			Split-Path -Path "$object_folder_file\$foldername\*.png-meta" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$foldername\$file_name")
						
						}
		
			}
			
		
			$xmlWriter.WriteElementString('name',"Document")
			$xmlWriter.WriteEndElement()
		}
		if($object_folder_file -eq "dashboards" )
		{
			$xmlWriter.WriteStartElement("types")
			$object_folder_inside= Get-ChildItem  $src\$object_folder_file  -Name -attributes D -Recurse > $src\$object_folder_file\folder_to_deploy.log
			foreach ($foldername in get-content $src\$object_folder_file\folder_to_deploy.log)
			{
			$xmlWriter.WriteElementString('members',"$foldername")
			cd $src
			Split-Path -Path "$object_folder_file\$foldername\*.dashboard" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$foldername\$file_name")
						
						}
			
			}
			
			$xmlWriter.WriteElementString('name',"dashboards")
			$xmlWriter.WriteEndElement()
		}
		<# if($object_folder_file -eq "sharingRules" )
		{
			$xmlWriter.WriteStartElement("types")
			$object_folder_inside= Get-ChildItem  $src\$object_folder_file  -Name -attributes D -Recurse > $src\$object_folder_file\folder_to_deploy.log
			foreach ($foldername in get-content $src\$object_folder_file\folder_to_deploy.log)
			{
			$xmlWriter.WriteElementString('members',"$foldername")
			cd $src
			Split-Path -Path "$object_folder_file\$foldername\*.sharingRules" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$foldername\$file_name")
						
						}
			
			}
			
			$xmlWriter.WriteElementString('name',"sharingRules")
			$xmlWriter.WriteEndElement()
		} #>
		if($object_folder_file -eq "reports" )
		{
			$xmlWriter.WriteStartElement("types")

			if(test-path  $src\$object_folder_file\*.xml)
				{
				cd $src
			Split-Path -Path "$object_folder_file\*.xml" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			
					foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{

							$xmlWriter.WriteElementString('members',"$filename")
						
						}
		

			#$xmlWriter.WriteElementString('name',"Report")
			#$xmlWriter.WriteEndElement()
				}

			
			#$xmlWriter.WriteStartElement("types")
			$object_folder_inside= Get-ChildItem  $src\$object_folder_file  -Name -attributes D -Recurse > $src\$object_folder_file\folder_to_deploy.log
			
			foreach ($foldername in get-content $src\$object_folder_file\folder_to_deploy.log)
			{
			$xmlWriter.WriteElementString('members',"$foldername")
			cd $src
			## Get-ChildItem  -Include *.xml, *.report -Recurse | % { $_.FullName }
			Split-Path -Path "$object_folder_file\*.cls" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			
			Split-Path -Path "$object_folder_file\$foldername\*.report" -Leaf -Resolve > $src\$object_folder_file\file_to_deploy.log
			#Split-Path -Path "$object_folder_file\*.xml" -Leaf -Resolve >> $src\$object_folder_file\file_to_deploy.log
			foreach ($filename in get-content $src\$object_folder_file\file_to_deploy.log)
						{
							$file_name=$filename.split('.')[0]
							write-host "$file_name"
							$xmlWriter.WriteElementString('members',"$foldername\$file_name")
						
						}
			
			}
			
		
			$xmlWriter.WriteElementString('name',"Report")
			$xmlWriter.WriteEndElement()
		}
		
		
}
$xmlWriter.WriteElementString('version',37.0)
$xmlWriter.WriteEndElement()
$xmlWriter.WriteEndDocument()
$xmlWriter.Flush()
$xmlWriter.Close()
########################################################################################################################
#########################################################################################################################
#SFDC Check-in Code


 cd $workspace\Core\Scripts
copy-item $src\package.xml . -force -recurse

remove-item $src\package.xml -force 
remove-item $src\List.txt -force 
get-childitem $src -include *.log -recurse | foreach ($_) {remove-item $_.fullname} 
cd $workspace\Core\src

copy-item $src\* . -force -recurse

cd "C:\GITSFDC\Core"
		git status 
		git add . 
		git commit -a -m "$checkincomments"
		git push

