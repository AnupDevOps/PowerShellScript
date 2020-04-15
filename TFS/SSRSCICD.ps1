Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$LocalReportsPath,
     
    [Parameter(Mandatory=$True,Position=2)]
    [string]$ReportServerUri,
     
    [Parameter(Mandatory=$True,Position=3)]
    [string]$DataSourceFolderName,
     
    [Parameter(Mandatory=$True,Position=4)]
    [string]$DataSetFolderName,

    [Parameter(Mandatory=$True,Position=5)]
    [string]$ReportsFolderName
)



function DeployAllItems()
{
echo “Refreshing reports”
echo “LocalReportsPath: $LocalReportsPath”;
echo “ReportServerUri: $ReportServerUri”;
echo “DataSource Folder: $DataSourceFolder”;
echo “DataSet Folder: $DataSetFolder”;
echo “Reports Folder: $ReportsFolder”;
echo “DataSource UserName: $DataSourceUserName”;
#Create SSRS Data Source , Dataset and Report Folders

##########################################
#Create DataSource Folder
Write-Verbose ""
try
{

$proxy.CreateFolder($DataSourceFolderName, $ReportsParentFolder, $null)
Write-Verbose "Created new folder: $DataSourceFolderName"
}
catch [System.Web.Services.Protocols.SoapException]
{
if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]")
{
Write-Verbose "Folder: $DataSourceFolderName already exists."
}
else
{
$msg = "Error creating folder: $DataSourceFolderName. Msg: '{0}'" -f $_.Exception.Detail.InnerText
Write-Error $msg
}
}
##########################################
##########################################
#Create DataSet Folder
Write-Verbose ""
try
{

$proxy.CreateFolder($DataSetFolderName, $ReportsParentFolder, $null)
Write-Verbose "Created new folder: $DataSetFolderName"
}
catch [System.Web.Services.Protocols.SoapException]
{
if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]")
{
Write-Verbose "Folder: $DataSetFolderName already exists."
}
else
{
$msg = "Error creating folder: $DataSetFolderName. Msg: '{0}'" -f $_.Exception.Detail.InnerText
Write-Error $msg
}
}
##########################################
##########################################
#Create Report Folder
Write-Verbose ""
try
{

$proxy.CreateFolder($ReportsFolderName, $ReportsParentFolder, $null)
Write-Verbose "Created new folder: $ReportsFolderName"
}
catch [System.Web.Services.Protocols.SoapException]
{
if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]")
{
Write-Verbose "Folder: $ReportsFolderName already exists."
}
else
{
$msg = "Error creating folder: $ReportsFolderName. Msg: '{0}'" -f $_.Exception.Detail.InnerText
Write-Error $msg
}
}
##########################################
#Create-SSRS-Report-Folders;
get-childitem $LocalReportsPath *.rds | DeployDataSources;
get-childitem $LocalReportsPath *.rsd | DeployDataSet;
get-childitem $LocalReportsPath *.rdl | DeployReports;
}

function DeployDataSources()
{

echo “Refreshing Datasources.”;
#Create SSRS Reports Folder
try{ $allitems = $proxy.ListChildren(“/”,$true); }catch{ throw $_.Exception; }

foreach ($o in $input)
{
$dataSourceInfo = $proxy.GetItemType(“$DataSourceFolder/$($o.BaseName)”);

echo “Creating DataSource $DataSourceFolder/$($o.BaseName)…”;


[xml]$XmlDataSourceDefinition = Get-Content $o.FullName;
$xmlDataSourceName = $XmlDataSourceDefinition.RptDataSource | where {$_ | get-member ConnectionProperties};
try{ $type = $proxy.GetType().Namespace; }catch{ throw $_.Exception; }
$dataSourceDefinitionType = ($type + ‘.DataSourceDefinition’);
$dataSourceDefinition = new-object ($dataSourceDefinitionType);
$dataSourceDefinition.Extension = $xmlDataSourceName.ConnectionProperties.Extension;
$dataSourceDefinition.ConnectString = "Data Source=.\SQL2012;Initial Catalog=AdventureWorks2012";

$credentialRetrievalDataType = ($type + ‘.CredentialRetrievalEnum’);
$credentialRetrieval = new-object ($credentialRetrievalDataType);
$credentialRetrieval.value__ = 1;# Stored
#$dataSourceDefinition.WindowsIntegratedSecurity = $true

$dataSourceDefinition.CredentialRetrieval = "Integrated";
#$dataSourceDefinition.WindowsCredentials = $true;
#$dataSourceDefinition.UserName = $DataSourceUserName;
#$dataSourceDefinition.Password = $DataSourcePassword;

try{ $newDataSource = $proxy.CreateDataSource($xmlDataSourceName.Name,$DataSourceFolder,$true,$dataSourceDefinition,$null);
    }catch{ throw $_.Exception; }
echo “Done.”;
}
echo “Finished.”;
}

function DeployDataSet()
{
echo “Refreshing DataSets.”;
try{ $allitems = $proxy.ListChildren(“/”,$true); }catch{ throw $_.Exception; }

foreach ($o in $input)
{
$dataSetInfo = $proxy.GetItemType(“$DataSetFolder/$($o.BaseName)”);

echo “Creating DataSet $DataSetFolder/$($o.BaseName)…”;
$stream = [System.IO.File]::ReadAllBytes( $($o.FullName));
$warnings =@();

#Create dataset item in the server
try{ $newDataSet = $proxy.CreateCatalogItem(“DataSet”,”$($o.BaseName)”,”$DataSetFolder”,$true,$stream,$null,[ref]$warnings);
     }catch{ throw $_.Exception; }
#relink dataset to datasource

echo “Updating Datasource reference”;
[xml]$XmlDataSetDefinition = Get-Content $o.FullName;
$xmlDataSourceReference = $XmlDataSetDefinition.SharedDataSet.DataSet | where {$_ | get-member Query};

try{ $dataSetDataSources = $proxy.GetItemDataSources(“$($newDataSet.Path)”); }catch{ throw $_.Exception; }
foreach ($dataSetDataSource in $dataSetDataSources)
{ #Should only be one!
$proxyNamespace = $dataSetDataSource.GetType().Namespace;
$newDataSourceReference = New-Object (“$proxyNamespace.DataSource”);
$newDataSourceReference.Name = $dataSetDataSource.Name;
$newDataSourceReference.Item = New-Object (“$proxyNamespace.DataSourceReference”);
$newDataSourceReference.Item.Reference = “$DataSourceFolder/$($xmlDataSourceReference.Query.DataSourceReference)”;
$dataSetDataSource.item = $newDataSourceReference.Item;
try { $proxy.SetItemDataSources(“$DataSetFolder/$($o.BaseName)”, $newDataSourceReference); }catch{ throw $_.Exception; }
}
echo “Done.”;
}
echo “Finished refreshing DataSets.”;
}

function DeployReports()
{
echo “Refreshing Reports.”;
try{ $allitems = $proxy.ListChildren(“/”,$true); }catch{ throw $_.Exception; }
$folderInfo = $proxy.GetItemType(“$ReportsFolder”);

# Iterate each report file
foreach ($o in $input)
{
#echo “Checking report $Folder/$($o.BaseName) exists on server.”;
try{ $reportInfo = $proxy.GetItemType(“$ReportsFolder/$($o.BaseName)”); }catch{ throw $_.Exception; }
echo “Creating report $ReportsFolder/$($o.BaseName)…”;
$stream = [System.IO.File]::ReadAllBytes( $($o.FullName));
$warnings =@();
try{ $newReport = $proxy.CreateCatalogItem(“Report”,”$($o.BaseName)”,”$ReportsFolder”,$true,$stream,$null,[ref]$warnings);
     }catch{throw $_.Exception; }

#relink report to datasource
echo “Updating Datasource references”;
try{ $reportDataSources = $proxy.GetItemDataSources(“$ReportsFolder/$($o.BaseName)”); }catch{ throw $_.Exception; }
foreach ($reportDataSource in $reportDataSources)
{
$serverDataSourceItem = $allitems | where {($_.TypeName -eq “DataSource”) -and ($_.Path -eq 
     “$DataSourceFolder/$($reportDataSource.Name)”)};
$proxyNamespace = $reportDataSource.GetType().Namespace;
$newDataSourceReference = New-Object (“$proxyNamespace.DataSource”);
$newDataSourceReference.Name = $reportDatasource.Name;
$newDataSourceReference.Item = New-Object (“$proxyNamespace.DataSourceReference”);
$newDataSourceReference.Item.Reference = $serverDataSourceItem.Path;
$reportDataSource.item = $newDataSourceReference.Item;
try{ $proxy.SetItemDataSources(“$ReportsFolder/$($o.BaseName)”, $newDataSourceReference); }catch{ throw $_.Exception; }
}

#relink report to shared datasets
echo “Updating DataSet references”;
[xml]$XmlReportDefinition = Get-Content $o.FullName;
if ($XmlReportDefinition.Report.DataSets.Dataset.count > 0)
{
$SharedDataSets = $XmlReportDefinition.Report.DataSets.Dataset | where {$_ | get-member SharedDataSet};
$DataSetReferences = @();
try{ $reportDataSetReferences = $proxy.GetItemReferences(“$ReportsFolder/$($o.BaseName)”, “DataSet”) | 
     where {$_.Reference -eq $null}; }catch{ throw $_.Exception; }
$newDataSetReferences = @();
foreach ($reportDataSetReference in $reportDataSetReferences)
{
$serverDataSetReference = $allitems | where {($_.TypeName -eq “DataSet”) -and 
    ($_.Path -eq “$DataSetFolder/$($reportDataSetReference.Name)”)};
$proxynamespace =$reportDataSetReference.Gettype().NameSpace;
$newDataSetReference = New-Object (“$proxyNamespace.ItemReference”);
$newDataSetReference.Name = $serverDataSetReference.Name;
$newDataSetReference.Reference = $serverDataSetReference.Path;
$newDataSetReferences += $newDataSetReference;
}
try{ $DataSetReferences += $proxy.SetItemReferences(“$ReportsFolder/$($o.BaseName)”, $newDataSetReferences);
    }catch{ throw $_.Exception; }

}
echo “Applying…”;
#try{ $proxy.SetPolicies(“$ReportsFolder/$($o.BaseName)”,$newPolicies); }catch{ throw $_.Exception; }
echo “Done.”;
}
echo “Finished refreshing Reports.”;
}

#Entry Point & Globals
#$LocalReportsPath = "C:/SSRSDrop";
#$ReportServerUri = "http://ssisvm/ReportServer/ReportService2010.asmx?wsdl";
$ReportsParentFolder = "/";

#$DataSourceFolderName = “Data Sources”;
#$DataSetFolderName = “Datasets”;
#$ReportsFolderName = “Reports”;


$DataSourceFolder = $ReportsParentFolder + $DataSourceFolderName ;
$DataSetFolder =  $ReportsParentFolder + $DataSetFolderName ;
$ReportsFolder =  $ReportsParentFolder + $ReportsFolderName ;



try{
#Create Proxy
$global:proxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential -ErrorAction Stop;
$valReportsServerUri = ($proxy -ne $null);
}
catch {
$valProxyError = $_.Exception.Message;
}

DeployAllItems;
echo “Done.”
