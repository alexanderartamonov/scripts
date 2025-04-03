cls
$computerName = $env:computerName
$log_archive_path = "D:\Log\"
$date = Get-Date -Format 'dd-MM'
$sevenZipPath = 'C:\\Program Files\\7-Zip\\7z.exe'

$fileList = "{{ LogFiles }}".Split(',')

foreach ($logfile in $fileList) {
    $logfile = $logfile.Trim()
    $archiveName = "$log_archive_path\$computerName-$date.zip"
    & "$sevenZipPath" a -mmt=16 -mx=3 -p"{{ ArchivePassword }}" $archiveName $logfile
}

aws s3 mv $archiveName s3://{{ S3Bucket }}/{{ S3Path }}/$computerName-$date.zip  