cls
$computerName=$env:computerName
$log_archive_path="D:\Log"
$drive_letter=$log_archive_path.Split('\')[0] 
$drive_letter
$date=$(Get-Date -Format 'dd-MM')
$S3_path="pic2022/ArchiveLogs/$computerName-$date.zip"


 
fsutil file createnew $log_archive_path\randomfile-$(Get-Random).txt 2048000000
fsutil file createnew $log_archive_path\randomfile-$(Get-Random).txt 2048000000
fsutil file createnew $log_archive_path\randomfile-$(Get-Random).txt 2048000000
fsutil file createnew $log_archive_path\randomfile-$(Get-Random).txt 2048000000
fsutil file createnew $log_archive_path\randomfile-$(Get-Random).txt 1024000000 


if ((Test-Path -Path $log_archive_path)) {
    #$VarSpaceInGb = $(Get-WmiObject -Class win32_logicaldisk | Where-Object -Property Name -eq D:).FreeSpace/1GB
    $VarSpaceInGb = $(Get-WmiObject -Class win32_logicaldisk | Where-Object -Property Name -eq '$drive_letter').FreeSpace/1GB
    $VarSpaceInPercentage = get-psdrive D | % { $_.free/($_.used + $_.free) } |% tostring p
    $files_created_date=$(get-childitem -Path "$log_archive_path" | where-object {$_.LastWriteTime -lt (get-date).AddDays(1)})
    
    if ([int]$VarSpaceInPercentage.trim('%') -gt 20) { 
        write-host "drive $drive_letter has more than 20% of free space: $VarSpaceInPercentage"
        write-host "In this case we do nothing..."
    }
      
    elseif ([int]$VarSpaceInPercentage.trim('%') -le 20) { 
        write-host "drive $drive_letter has less than 20% of free space: $VarSpaceInPercentage"
        write-host "In this case we check that files are older than 1 days or not..."
                if ($files_created_date) {
                    Write-Host "Files created more than 1 days ago were found: $files_created_date"
                    Write-Host "Now we archive them, move to s3 and remove from ec2"
                    & "C:\Program Files\7-Zip\7z.exe" a -mmt=16 -mx=3 $log_archive_path\$computerName-$date.zip $log_archive_path |
                    aws s3 mv $log_archive_path\$computerName-$date.zip s3://pic2022/ArchiveLogs/$computerName-$date.zip
                    Get-ChildItem -Path $log_archive_path -Include *.* -File -Recurse | foreach { $_.Delete()}
                      
                }
                else {
                    Write-Host "Files created more than 1 days ago were not found: $files_created_date"
                }
        }
    }    
