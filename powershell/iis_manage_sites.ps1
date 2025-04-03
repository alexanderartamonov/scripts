cls
Import-Module IISAdministration
Import-Module WebAdministration

$SiteName = 'chaos-loadtest'
$HostName = 'localhost'
$SiteFolder ='D:\wwwroot\LoadTest\'

$portcounter=9
for($i=0;$i -le 21;$i++){

    if(get-website | where-object { $_.name -eq "$SiteName-$i"}){
        write-host "site $SiteName$i exists"
    }
    else {
            $portcounter++
            write-host "site $SiteName-$i does not exist, let's create"
            New-WebAppPool -Name $SiteName-$i -Force
            New-Website -Name $SiteName-$i -PhysicalPath $SiteFolder -ApplicationPool $SiteName-$i -Port 80$portcounter -IPAddress 127.0.0.1 -Force       
     }
}  



####remove websites#####
cls
Import-Module IISAdministration
Import-Module IISAdministration

$SiteName = "chaos-loadtest"
$HostName = "localhost"
$SiteFolder ='D:\wwwroot\Applight\'
  
 for($i=0;$i -le 21;$i++){
     if(get-website | where-object { $_.name -eq "$SiteName-$i"}){
         write-host "site $SiteName$i exists, cleaning up"
         Remove-WebAppPool -Name $SiteName-$i
         Remove-Website -Name $SiteName-$i
     }
     else {
             write-host "site $SiteName-$i does not exist"   
      }
 }
   
 

