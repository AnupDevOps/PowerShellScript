Function Remove-DockerContainers
{
    # save containers ids into array (--quiet mean return just containers ids)
    $containersIds = (docker ps --all --quiet); 
    if ($containersIds.Count -gt 0)
    {
        Write-Host ("removing docker containers: ")
        # stop all containers
        docker stop $containersIds
        # remove all containers
        docker rm $containersIds
    }
}
Function Remove-DockerImage
{
    Param (
        [Parameter(Mandatory=$True)]
        [string]$DockerImage
    )
    # try find image(s) by name
    $selectedDockerImages = (docker images --all $DockerImage --quiet)
    if ($selectedDockerImages.Count -gt 0) 
    {
        # remove image(s)
        docker rmi $DockerImage
        Write-Host ($DockerImage + " image was removed") -ForegroundColor Green
    } else {
        # show mesage that docker image does not exist
        Write-Host ($DockerImage + " image not exists")  -ForegroundColor Red
    }
} 
Function Remove-DockerImages
{
    Param (
        [Parameter(Mandatory=$True)]
        [string[]]$DockerImages
    )
    Write-Host ("removing docker images: ")
    foreach ($DockerImage in $DockerImages)
    {
        Remove-DockerImage -DockerImage $DockerImage
    }
}
# Array of docker images we want to remove
$dockerImagesToRemove = @(Read-Host "Enter the Images Name to delete")
Remove-DockerContainers
Remove-DockerImages -DockerImages $dockerImagesToRemove


