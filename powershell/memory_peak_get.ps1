    # Get Computer Object
    Import-Module IISAdministration
    Import-Module WebAdministration
    $computerName=$env:computerName
    $INSTANCEIP=$(Invoke-RestMethod -UseBasicParsing -Uri '169.254.169.254/latest/meta-data/local-ipv4')
    $CompObject =  Get-WmiObject -Class WIN32_OperatingSystem
    $demical = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory)*100)/ $CompObject.TotalVisibleMemorySize)
    $Memory = [math]::Round($demical,2)
    Write-Host "Memory usage in Percentage:" $Memory `n 
          
    # Top 5 process Memory Usage (MB)
    $processMemoryUsage = Get-Process -IncludeUserName| 
    Sort-Object -Property ws -Descending | 
    Select-Object  ProcessName,Id,UserName,@{Name="WS(MB)";Expression={[math]::round($_.ws / 1mb)}} | Where-Object ProcessName -eq 'w3wp' 
    ForEach($i in $processMemoryUsage | select -first 5) {
             $i
    }  
   
 