$disk = Get-WmiObject Win32_LogicalDisk -ComputerName '.' -Filter "DeviceID='S:'" | Select-Object Size, FreeSpace
$totalSpace = ([math]::Round($disk.Size / 1GB, 2))
$freeSpace = ([math]::Round($disk.FreeSpace / 1GB, 2))
Write-Host "Size of S drive" $totalSpace GB
Write-Host "Free space on S drive" $freeSpace GB  

# To delete whole images in one run use below code 
$selectedDockerImages = (docker images --all --quiet)
foreach($imagename in $selectedDockerImages)
{
docker rmi $imagename --force
}

# Stopping a Container and removing a container with his name. 

$Dockername = Read-Host 'Enter the Conatiner name'

$dockerID = docker inspect --format="{{.ID}}" $Dockername
docker stop $dockerID
docker rm $dockerID
