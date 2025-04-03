cls
#set-executionpolicy unrestricted -Force
Set-ExecutionPolicy Bypass -Scope Process -Force
Import-Module -Name ServerManager
Import-Module Dism
Get-WindowsFeature

############################################################################################
# Disable WCF Services
############################################################################################
Disable-WindowsOptionalFeature -Online -FeatureName WCF-Services45 -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName WCF-HTTP-Activation45 -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName WCF-TCP-Activation45 -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName WCF-Pipe-Activation45 -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName WCF-MSMQ-Activation45 -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName WCF-TCP-PortSharing45 -NoRestart


############################################################################################
# Disable Management Tools
Disable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementService -NoRestart 
Disable-WindowsOptionalFeature -Online -FeatureName IIS-LegacyScripts -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-LegacySnapIn -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementScriptingTools -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-WMICompatibility -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools -NoRestart
############################################################################################


############################################################################################
# Disable Application Development Tools
# Disable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All -NoRestart
# Disable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment -NoRestart
############################################################################################

############################################################################################
# Disable Security Tools
Disable-WindowsOptionalFeature -Online -FeatureName IIS-IPSecurity -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-IISCertificateMappingAuthentication -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-ClientCertificateMappingAuthentication -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-CertProvider -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication -NoRestart 
Disable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering -NoRestart
# Disable-WindowsOptionalFeature -Online -FeatureName IIS-Security -NoRestart
############################################################################################

############################################################################################
# Disable Performance Tools
Disable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic -NoRestart
# Disable-WindowsOptionalFeature -Online -FeatureName IIS-Performance -NoRestart
############################################################################################

############################################################################################
# Disable Health and Diagnostics Tools
# Disable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics -NoRestart
############################################################################################

Disable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-CustomLogging -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging -NoRestart

############################################################################################
# Disable Common HTTP Features
############################################################################################

Disable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-DirectoryBrowsing -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -NoRestart
# Disable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures -NoRestart

############################################################################################
# Disable Windows Features
############################################################################################

Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -NoRestart

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
Restart-Computer  
