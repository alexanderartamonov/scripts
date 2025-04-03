
cls
$directoryPath = "D:\taskscheduler"
$S3BucketName="{{ bucketName }}"
$S3BucketPath="{{ s3path }}"
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.254.*' } | Select-Object -ExpandProperty IPAddress)[0]
$outputCsv = "$directoryPath\$ipAddress.csv"

if (Test-Path -Path $directoryPath) {
    Write-Output "The directory '$directoryPath' already exists."
} else {
    New-Item -Path $directoryPath -ItemType Directory
    Write-Output "The directory '$directoryPath' has been created."
}

    $ScheduledTasks = Get-ScheduledTask | ForEach-Object {
    $ScheduledTasksInfo = $_ | Get-ScheduledTaskInfo
    $status = if ($_.State -eq 'Disabled') { 
        "Disabled"
    } elseif ($_.State -eq 'Ready') {
        "Ready"
    } else {
        "Other" 
    }

    $triggers = $_.Triggers | ForEach-Object {
        $triggerType = if ($_.StartBoundary -and !$_.Repetition.Interval) {
            "One time"
        } elseif ($_.TriggerType -eq 'DailyTrigger') {
            "Daily"
        } elseif ($_.TriggerType -eq 'WeeklyTrigger') {
            "Weekly"
        } elseif ($_.TriggerType -eq 'MonthlyTrigger') {
            "Monthly"
        } else {
            "Other"
        }

        $startBoundary = $_.StartBoundary
        $enabled = $_.Enabled  
        $repeatInterval = if ($_.Repetition.Interval) { $_.Repetition.Interval } else { "None" }  
        $repeatDuration = if ($_.Repetition.Duration) { $_.Repetition.Duration } else { "Indefinite" } 
        $stopIfLongerThan = if ($_.ExecutionTimeLimit) { $_.ExecutionTimeLimit } else { "Unlimited" } 

        [PSCustomObject]@{
            TriggerType       = $triggerType
            StartBoundary     = $startBoundary
            Enabled           = $enabled
            RepeatTaskEvery   = $repeatInterval
            ForDurationOf     = $repeatDuration
            StopIfRunsLonger  = $stopIfLongerThan
        }
    }

    $actions = $_.Actions | ForEach-Object {
        $getActionsProperties = "$($_.ActionType) $($_.Execute) $($_.Arguments)"
        $startIn = $_.WorkingDirectory
        [PSCustomObject]@{
            ActionProperties = $getActionsProperties
            StartIn     = $startIn
        }
    }

    [PSCustomObject]@{
        TaskName              = $_.TaskName
        UserAccount           = $_.Principal.UserId
        TaskPath              = $_.TaskPath
        "Do not Store Password" = if ($_.Principal.LogonType -eq 'Password') { $false } else { $true }
        NextRunTime           = $ScheduledTasksInfo.NextRunTime
        Status                = $status
        Triggers              = $triggers
        ActionProperties     = $actions.ActionProperties -join ", "
    }
}


$ScheduledTasks | Export-Csv -Path $outputCsv -NoTypeInformation
Write-Host "Scheduled tasks have been exported to $outputCsv"
aws s3 cp $outputCsv s3://$S3BucketName/$S3BucketPath/

if (Test-Path -Path $directoryPath) {
    Remove-Item -Path $directoryPath -Recurse -Force
    Write-Output "The directory '$directoryPath' has been deleted."
} else {
    Write-Output "The directory '$directoryPath' does not exist."
}     