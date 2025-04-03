cls
#set-executionpolicy unrestricted -Force
Set-ExecutionPolicy Bypass -Scope Process -Force
Import-Module -Name ServerManager
Import-Module Dism
Get-WindowsFeature
Install-WindowsFeature Web-Server -IncludeManagementTools

$IISOptionalFeatures = 
"IIS-WebServerRole"
"IIS-WebServer",
"IIS-DefaultDocument",
"IIS-HttpErrors",
"IIS-DirectoryBrowsing",
"IIS-StaticContent",
"IIS-HttpRedirect",
"IIS-HttpLogging",
"IIS-CustomLogging",
"IIS-LoggingLibraries",
"IIS-HttpTracing",
"IIS-HttpCompressionStatic",
"IIS-RequestFiltering",
"IIS-BasicAuthentication",
"IIS-CertProvider",
"IIS-ClientCertificateMappingAuthentication",
"IIS-IISCertificateMappingAuthentication",
"IIS-IPSecurity",
"IIS-WebServerManagementTools",
"IIS-ManagementConsole",
"IIS-IIS6ManagementCompatibility",
"IIS-Metabase",
"IIS-WMICompatibility",
"IIS-ManagementScriptingTools",
"IIS-LegacySnapIn",
"IIS-LegacyScripts",
"IIS-ManagementService",
"WCF-TCP-PortSharing45",
"WCF-MSMQ-Activation45",
"WCF-Pipe-Activation45",
"WCF-TCP-Activation45",
"WCF-HTTP-Activation45",
"WCF-Services45"
Enable-WindowsOptionalFeature -Online -FeatureName $IISOptionalFeatures

$service = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
if ($service.Length -gt 1) {
    Write-Host Service $service is disabled
}
else {
Write-Host Service $service is enabled, need to investigate further
}
Get-WindowsFeature
Start-Sleep - Seconds 5
#Restart-Computer