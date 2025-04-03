$urls = @(
    'http://localhost:8010',
    'http://localhost:8011',
    'http://localhost:8012',
    'http://localhost:8013',
    'http://localhost:8014',
    'http://localhost:8015',
    'http://localhost:8016',
    'http://localhost:8017',
    'http://localhost:8018',
    'http://localhost:8019',
    'http://localhost:8020',
    'http://localhost:8021',
    'http://localhost:8022',
    'http://localhost:8023',
    'http://localhost:8024',
    'http://localhost:8025',
    'http://localhost:8026',
    'http://localhost:8027',
    'http://localhost:8028',
    'http://localhost:8029',
    'http://localhost:8030',
    'http://localhost:8031'    
    )  

$timeout = new-timespan -Minutes 5
$sw = [diagnostics.stopwatch]::StartNew()  
$Body = @{
search = "search index=_internal | reverse | table index,host,source,sourcetype,_raw"
output_mode = "csv"
}
while ($sw.elapsed -lt $timeout){
# while(-1) {
for($i=0; $i -le $urls.length-1; $i++) {
    Invoke-RestMethod -Method 'Get'-Uri $urls[$i] -ContentType "application/json" -WebSession $loadtest -Body $body -OutFile C:\output.csv 
}
}  
