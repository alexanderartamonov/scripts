cls
$username = "test-archive-log-username"
$password = "test-archive-log-password"
$DirectoryPath = "D:\taskscheduler\"
$sourceReportCSV = "172.31.22.157.csv"

$triggerType="OneTime"
$repeatInterval="01:30:00"
$duration=""
$stopIfRunsLonger=""
$enableTrigger="True"
$programScript="powershell.exe"
$addArguments="-File C:\some.exe"
$startIn="some path"

if (!(Test-Path -Path $DirectoryPath)) {
    New-Item -Path $DirectoryPath -ItemType Directory
    Write-Output "The directory '$DirectoryPath' has been created."
} 

$csvData = Import-Csv -Path $DirectoryPath\$sourceReportCSV

Write-Host `n"Data to Import into Scheduled Tasks:"`n
foreach ($line in $csvData) {
    Write-Host $line.'TaskName', $line.'UserAccount', $line.'TaskPath', $line.'Do not Store Password', $line.'NextRunTime', $line.'Status'
}

$ssm_username = (aws ssm get-parameter --region ap-southeast-1 --name $username --query "Parameter.Value" --output text)
$ssm_password = (aws ssm get-parameter --region ap-southeast-1 --name $password --query "Parameter.Value" --output text)

function Create-ScheduledTaskTrigger {
    param (
        [string]$triggerType,
        [DateTime]$runTime,
        [TimeSpan]$repeatInterval = $null,
        [TimeSpan]$duration = $null
    )

    if (-not $repeatInterval -or -not $duration) {
        switch ($triggerType) {
            "OneTime" {
                return New-ScheduledTaskTrigger -At $runTime -Once
            }
            "Daily" {
                return New-ScheduledTaskTrigger -Daily -At $runTime
            }
            "Weekly" {
                return New-ScheduledTaskTrigger -Weekly -At $runTime -DaysOfWeek Monday
            }
            "Monthly" {
                return New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek Monday -At $runTime
            }
        }
    }
    if ($repeatInterval -and $duration -and $repeatInterval.TotalSeconds -gt 0 -and $duration.TotalSeconds -gt 0 ) { 
        switch ($triggerType) {
            "OneTime" {
                return New-ScheduledTaskTrigger -At $runTime -Once -RepetitionInterval $repeatInterval -RepetitionDuration $duration
            }
        }
    }
    if ($repeatInterval -and $repeatInterval.TotalSeconds -gt 0) { 
        switch ($triggerType) {
            "OneTime" {
                return New-ScheduledTaskTrigger -At $runTime -Once -RepetitionInterval $repeatInterval
            }
        }
    }

    Write-Host "Missing or invalid repetition interval or duration. Values must be greater than zero."
    return $null
}
$csvData | ForEach-Object {
    $taskName = $_.TaskName
    $userAccount = $_."UserAccount"
    $taskPath = $_."TaskPath"
    $doNotStorePassword = $_."Do not Store Password"
    $status = $_."Status"
    $nextRunTime = $_."NextRunTime"
    
    try {
        $existingTask = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Host "Task '$taskPath\$taskName' already exists. Disabling it and skipping creation."
            break
            try {
                Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName
                Write-Host "Task '$taskPath\$taskName' has been disabled."
            } catch {
                Write-Host "Failed to disable task '$taskPath\$taskName': $_"
            }
            return
        }
    } catch {
        Write-Host "No tasks found, continue"
    }

    $actionScript = if ($programScript) { $programScript } else { "powershell.exe" }
    $actionArgs = if ($addArguments) { $addArguments } else { "" }
    $startDirectory = if ($startIn) { $startIn } else { "" }
    $action = New-ScheduledTaskAction -Execute $actionScript -Argument $actionArgs -WorkingDirectory $startDirectory
    $trigger = $null
    $runTime = $null
    if (-not [string]::IsNullOrWhiteSpace($nextRunTime)) {
        try { $runTime = [DateTime]::Parse($nextRunTime)
        } catch {
            Write-Host "Invalid date format for task '$taskName'."
        }
    }

    if (-not $runTime) {
        Write-Host "No valid 'nextRunTime' provided. Using default time of 9:00 AM."
        $runTime = (Get-Date).Date.AddHours(9)
    }

    $validRepeatInterval = if (-not [string]::IsNullOrWhiteSpace($repeatInterval)) {
        [System.TimeSpan]::Parse($repeatInterval)  # Convert to TimeSpan if valid
    } else {
        [System.TimeSpan]::Zero  # Default to zero if not valid
    }

    $validDuration = if (-not [string]::IsNullOrWhiteSpace($duration)) {
        [System.TimeSpan]::Parse($duration)  # Convert to TimeSpan if valid
    } else {
        [System.TimeSpan]::Zero  # Default to zero if not valid
    }
    $trigger = Create-ScheduledTaskTrigger -triggerType $triggerType -runTime $runTime  -repeatInterval $validRepeatInterval  -duration $validDuration
    if (-not [string]::IsNullOrWhiteSpace($stopIfRunsLonger)) {
        try {
            $timeSpan = [System.TimeSpan]::ParseExact($stopIfRunsLonger, "hh\:mm\:ss", $null)
            $trigger.ExecutionTimeLimit = "PT{0}H{1}M{2}S" -f $timeSpan.Hours, $timeSpan.Minutes, $timeSpan.Seconds
        } catch {
            Write-Host "Invalid format for Stop Task if runs longer than: $stopIfRunsLonger. Expected format is 'hh:mm:ss'."
        }
    }
    $principal = New-ScheduledTaskPrincipal -UserId $ssm_username -LogonType Password
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    try {
        if ($enableTrigger -eq "True") {
            Register-ScheduledTask -TaskPath $taskPath -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -User $ssm_username -Password $ssm_password
            Disable-ScheduledTask -TaskName $taskName
            Write-Host "Task '$newTaskName' has been imported successfully with trigger." 
              
        } elseif ($enableTrigger -eq "False"){
            Register-ScheduledTask -TaskPath $taskPath -TaskName $taskName -Action $action -Settings $settings -User $ssm_username -Password $ssm_password
            Disable-ScheduledTask -TaskName $taskName
            Write-Host "Task '$taskName' has been imported successfully without trigger."    
        }

    } catch {
        Write-Host "Failed to import task '$taskName': $_"
    }


  }  
