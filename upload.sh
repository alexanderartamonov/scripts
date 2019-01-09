#!/bin/bash
TOKEN=token
url=url
#for file in /tmp/TA_results/*.tar.gz
#do
latest=$(find . -name \*.tar.\* -execdir sh -c "echo -n \" \"; ls -t *.tar.* | head -n 1" \; | sort -u -k1,1)
echo " uploading latest $latest "
curl -H "X-JFrog-Art-Api: $TOKEN" -T $latest $url
#done
