cls
#set-executionpolicy unrestricted -Force
Set-ExecutionPolicy Bypass -Scope Process -Force
Import-Module -Name ServerManager
Import-Module Dism

############################################################################################
# Windows Feature
############################################################################################
Install-WindowsFeature -name Web-Server  -IncludeManagementTools

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer

############################################################################################
# Common HTTP Features
# Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
############################################################################################

Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DirectoryBrowsing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect

############################################################################################
# Health and Diagnostics
# Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
############################################################################################

Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CustomLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing

############################################################################################
# Performance
# Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
############################################################################################

Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic

############################################################################################
# Security
# Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
############################################################################################

Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CertProvider
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ClientCertificateMappingAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IISCertificateMappingAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IPSecurity

############################################################################################
# Application Development
# Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
############################################################################################

# Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All

############################################################################################
# Management Tools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
############################################################################################

Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WMICompatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementScriptingTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LegacySnapIn
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LegacyScripts
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementService

############################################################################################
# FTP Server
############################################################################################
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-FTPServer
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-FTPSvc
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-FTPExtensibility 


############################################################################################
# WCF Services
Get-WindowsOptionalFeature -Online | Where-Object {$_.State -like "Disabled" -and $_.FeatureName -like "*WCF*"} | % {Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All}
############################################################################################
#Enable-WindowsOptionalFeature -Online -FeatureName WCF-Services45
#Enable-WindowsOptionalFeature -Online -FeatureName WCF-HTTP-Activation45
#Enable-WindowsOptionalFeature -Online -FeatureName WCF-TCP-Activation45
#Enable-WindowsOptionalFeature -Online -FeatureName WCF-Pipe-Activation45
#Enable-WindowsOptionalFeature -Online -FeatureName WCF-MSMQ-Activation45
#Enable-WindowsOptionalFeature -Online -FeatureName WCF-TCP-PortSharing45 

 #Wait until IIS is up and running
 $req = [system.Net.WebRequest]::Create($url)
 try {
     $res = $req.GetResponse()
 } 
 catch [System.Net.WebException] {
     $res = $_.Exception.Response
 }
 $result_status = $res.StatusCode
 #OK
 $result_code = [int]$res.StatusCode
 #200
 
 if (($result_code = '200') -or ($result_status = 'OK')) { Write-Host "IIS is reachable" -ForegroundColor Green }
 Else { Write-Host "IIS is not reachable" -ForegroundColor Red } 
 