    cls
    Set-PSDebug -Trace 0
    $date=$(Get-Date -Format 'dd-MM-yyyy-HH')
    $name=$env:computerName
    $hostname=$(Invoke-Expression -Command 'Hostname')
    $HOOKRESULT='CONTINUE'
    $MESSAGE='message message'
    $INSTANCEID=$(Invoke-RestMethod -UseBasicParsing -Uri '169.254.169.254/latest/meta-data/instance-id')
    $INSTANCEIP=$(Invoke-RestMethod -UseBasicParsing -Uri '169.254.169.254/latest/meta-data/local-ipv4')
    Write-Host instance id is: $INSTANCEID and instance ipv4 is: $INSTANCEIP
    $service1 = Get-Service -Name SinaptIQ.SSLPost -ErrorAction SilentlyContinue
    $service2 = Get-Service -Name SSLPostWinService -ErrorAction SilentlyContinue
    if ($service1 -eq $null) {
    Write-Host SinaptIQ.SSLPost does not exist
    } else {
    Write-Host SinaptIQ.SSLPost exists
    Stop-Service -Name SinaptIQ.SSLPost
    }
    if ($service2 -eq $null) {
    Write-Host SSLPostWinService does not exist
    } else {
    Write-Host SSLPostWinService exists
    Stop-Service -Name SSLPostWinService
    }
    if(Test-Path -Path 'D:/Log') {
    $compresslog=$(Invoke-Expression -Command 'Compress-Archive -Path D:/Log -DestinationPath D:/Log/Log-$name-$date.zip -Force -CompressionLevel Fastest')
    #aws s3 cp D:/Log/Log-$name-$date.zip s3://pic2022/EC2Logs/Log-$name-$date.zip
    } 
    elseif(Test-Path -Path 'D:/Logs') {
    $compresslog=$(Invoke-Expression -Command 'Compress-Archive -Path D:/Logs -DestinationPath D:/Logs/Logs-$name-$date.zip -Force -CompressionLevel Fastest')
    #aws s3 cp D:/Logs/Logs-$name-$date.zip s3://pic2022/EC2Logs/Logs-$name-$date.zip
    } 
    else {
    Write-Host logs folders where not found!
    } 
