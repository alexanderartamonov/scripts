cls
$date=$(Get-Date -Format "dd-MM-yyyy-HH-mm") 
$name=$env:computerName
iisreset /stop
Stop-Service SinaptIQ.SSLPost
Stop-Service SSLPostWinService
sleep 2
if (Test-Path -Path D:\Log) {
Compress-Archive -Path D:\Log -Force -CompressionLevel Fastest -DestinationPath  D:\Log\$name-$date.zip 
sleep 5
aws s3 cp D:\Log\$name-$date.zip  s3://pic2022/Log/$name-$date.zip 
}
elseif(Test-Path -Path D:\Logs) {
Compress-Archive -Path D:\Logs -Force -CompressionLevel Fastest -DestinationPath  D:\Logs\$name-$date.zip 
sleep 5
aws s3 cp D:\Logs\$name-$date.zip  s3://pic2022/Logs/$name-$date.zip 
}  
