cls
#Add-WindowsFeature Web-Scripting-Tools
Import-Module -Name ServerManager
Import-Module Dism
$hostname = $env:ComputersName
#Install-WindowsFeature -name Web-Server  -IncludeManagementTools #-IncludeAllSubFeature
Install-WindowsFeature -name Web-Server -IncludeAllSubFeature -IncludeManagementTools
Get-WindowsFeature
$service = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
if ($service.Length -gt 0) {
    Write-Host Service $service exists and setting it for auto startup
    Set-Service -name W3SVC -startupType Automatic
}
else {
Write-Host Service $service does not exist
}
#Get-WindowsOptionalFeature -Online -Object {$_.State -like "Disabled" -and $_.FeatureName -like "*WCF*"} | % {Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All}
Get-WindowsOptionalFeature -Online | Where-Object {$_.State -like "Disabled" -and $_.FeatureName -like "*WCF*"} | % {Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All} 
