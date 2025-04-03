cls
$S3BucketName="2c2p-uat-infra"
$S3BucketPath="windows_taskscheduler_csv_report"
$sourceReportCSV="172.31.22.11.csv"
$DirectoryPath = "D:\taskscheduler"


if (Test-Path -Path $DirectoryPath) {
    Write-Output "The directory '$DirectoryPath' already exists."
} else {
    # Create the directory
    New-Item -Path $DirectoryPath -ItemType Directory
    Write-Output "The directory '$DirectoryPath' has been created."
}
aws s3 cp s3://$S3BucketName/$S3BucketPath/$sourceReportCSV $DirectoryPath\$sourceReportCSV

$csvData = Import-Csv -Path $DirectoryPath\$sourceReportCSV

Write-Host `n"Data to Import into Scheduled Tasks:"`n
foreach ($line in $csvData) {
    Write-Host $line.'TaskName', $line.'UserAccount', $line.'TaskPath' ,$line.'Do not Store Password', $line.'NextRunTime', $line.'Status'
}
$userAccount = "administrator"
$password="2c2pP@ssw0rd"

$csvData | ForEach-Object {
    $taskName = $_.TaskName
    $userAccount = $_."UserAccount"
    $taskPath = $_."TaskPath"
    $doNotStorePassword = $_."Do not Store Password"
    $status = $_."Status"
    $nextRunTime = $_."NextRunTime"

    try {
        $user = New-Object System.Security.Principal.NTAccount($userAccount)
        $user.Translate([System.Security.Principal.SecurityIdentifier])
    } catch {
        Write-Host "User account '$userAccount' cannot be resolved. Using 'ansibleservice' instead."
        $userAccount = "administrator"
    }

    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Write-Host "Task '$taskName' already exists. Skipping creation."
        return  # Skip to the next task
    }

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $taskPath"
    $trigger = New-ScheduledTaskTrigger -At $nextRunTime -Once
    $principal = New-ScheduledTaskPrincipal -UserId $userAccount -LogonType Password
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    try {
        Register-ScheduledTask -TaskName $taskName -Action $action  -Trigger $trigger -Settings $settings -User $userAccount -Password $password

        # Set the status if the task is disabled
        if ($status -eq 'Disabled') {
            Disable-ScheduledTask -TaskName $taskName
        }

        Write-Host "Task '$taskName' has been imported successfully."

    } catch {
        Write-Host "Failed to import task '$taskName': $_"
    }
}
 
