cls
#set-executionpolicy unrestricted -Force
Set-ExecutionPolicy Bypass -Scope Process -Force
Import-Module -Name ServerManager
Import-Module Dism
Get-WindowsFeature

$IISOptionalFeatures = 
"WCF-Services45",
"WCF-HTTP-Activation45",
"WCF-TCP-Activation45",
"WCF-Pipe-Activation45",
"WCF-MSMQ-Activation45",
"WCF-TCP-PortSharing45",
"IIS-ManagementService",
"IIS-LegacyScripts",
"IIS-LegacySnapIn",
"IIS-ManagementScriptingTools",
"IIS-WMICompatibility",
"IIS-Metabase",
"IIS-IIS6ManagementCompatibility",
"IIS-ManagementConsole",
"IIS-WebServerManagementTools",
"IIS-IPSecurity",
"IIS-IISCertificateMappingAuthentication",
"IIS-ClientCertificateMappingAuthentication",
"IIS-CertProvider",
"IIS-BasicAuthentication",
"IIS-RequestFiltering",
"IIS-HttpCompressionStatic",
"IIS-HttpTracing",
"IIS-LoggingLibraries",
"IIS-CustomLogging",
"IIS-HttpLogging",
"IIS-HttpRedirect",
"IIS-StaticContent",
"IIS-DirectoryBrowsing",
"IIS-HttpErrors",
"IIS-DefaultDocument",
"IIS-WebServer",
"IIS-WebServerRole"
Disable-WindowsOptionalFeature -Online -FeatureName $IISOptionalFeatures -NoRestart -Remove

Uninstall-WindowsFeature -Remove Web-Server -IncludeManagementTools
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