# Specify the path to the Excel file and the WorkSheet Name
$FilePath = "F:\Tmp\UserRole2.xlsx"
$SheetName = "Sheet1"

# Create an Object Excel.Application using Com interface
$objExcel = New-Object -ComObject Excel.Application

# Disable the 'visible' property so the document won't open in excel
$objExcel.Visible = $false

# Open the Excel file and save it in $WorkBook
$WorkBook = $objExcel.Workbooks.Open($FilePath)

# Load the WorkSheet 'BuildSpecs'
$WorkSheet = $WorkBook.sheets.item($SheetName)

#[pscustomobject][ordered]@{
    $UserName = $WorkSheet.Range("A2").Text
    $ADGroupName = $WorkSheet.Range("B2").Text
#}
$UserName
$ADGroupName
$rowMax = ($WorkSheet.UsedRange.Rows).count

$objExcel.Workbooks.Close()