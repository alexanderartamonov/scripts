$hostname = $env:COMPUTERNAME
if (Test-Connection -ComputerName $hostname -Quiet -Count 1){
    $result = query session /server:$hostname
    $rows = $result -split "`n" 
    foreach ($row in $rows | Where-Object {$row.Name -ne "Administrator" -and $row.Name -ne "administrator" -and $row.Name -ne "prod\administrator"}) 
       {   
        if ($row -NotMatch "services|console" -and $row -match "Disc") {
            $sessionusername = $row.Substring(19,20).Trim()
            $sessionid = $row.Substring(39,9).Trim()
            Write-Output "Logging Off RDP Disconnected Sessions User $sessionusername"
            logoff $sessionid /server:$hostname
        }
        else {
            Write-Output "No RDP users found for logoff"
        }
    }
} 
 
