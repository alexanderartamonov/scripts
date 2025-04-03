   # Get Computer Object
   Import-Module IISAdministration
   Import-Module WebAdministration
   $computerName=$env:computerName
   $INSTANCEIP=$(Invoke-RestMethod -UseBasicParsing -Uri '169.254.169.254/latest/meta-data/local-ipv4')
   $CompObject =  Get-WmiObject -Class WIN32_OperatingSystem
   $demical = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory)*100)/ $CompObject.TotalVisibleMemorySize)
   $Memory = [math]::Round($demical,2)
   Write-Host "Memory usage in Percentage:" $Memory `n 
   $processMemoryUsage = Get-Process -IncludeUserName| 
   Sort-Object -Property ws -Descending | 
   Select-Object -first 5 ProcessName,Id,UserName,@{Name="WS(MB)";Expression={[math]::round($_.ws / 1mb)}} | Where-Object ProcessName -eq 'w3wp'
   ForEach($i in $processMemoryUsage | select -first 5) {
		 $appoolusername=$i.UserName.split('\')[1]
		 ForEach ($appools in $appoolusername) {
			 $result=$(Get-IISAppPool -Name $appoolusername | Select-Object Name,State)
			 $result.Name
			 $result.State
			 if ($result.State -eq "Started") {
					 Write-Host ("ApppPool already running")
					 Write-Host "App Pool Recycling Started...." -ForegroundColor Yellow 
					 Restart-WebAppPool -Name $result.Name 
					 Write-Host "App Pool Recycling Completed" -ForegroundColor Green
			 }
			 else {
					 Start-WebAppPool -Name $appool.Name
					 Write-host ("AppPool has started successfully") 
			 } 
		 }
   } 
 