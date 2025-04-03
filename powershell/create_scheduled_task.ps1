$username = (Get-SSMParameterValue -Name test-archive-log-username).Parameters[0].Value
$password = (Get-SSMParameterValue -Name test-archive-log-password).Parameters[0].Value
aws s3 cp s3://pic2022/archive_log_checkdisk.ps1 D:\archive_log_checkdisk.ps1
$Action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument '-NonInteractive -NoLogo -NoProfile -File "D:\archive_log_checkdisk.ps1"'
$Trigger = New-ScheduledTaskTrigger -Once -At 10am
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName 'Check disk space and archive logs' -InputObject $Task -User $username -Password $password

powershell.exe 'D:\archive_log_checkdisk.ps1'