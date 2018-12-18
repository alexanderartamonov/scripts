#!/bin/bash
URL=https://artifactory.corp.ad.ctc/artifactory/npm-cds-local/automation-reports/
CUTS=`echo ${URL#http://} | awk -F '/' '{print NF -2}'`
FILE=./file
if [-e $FILE]; then
   echo "FILE $FILE exists..."
else
   echo "File $FILE does not exist."
   wget --no-check-certificate -r -l1 -nH --cut-dirs=${CUTS} --no-parent -A.tar.gz --no-directories -R robots.txt ${URL}
fi

for a in *.tar.gz
do
    a_dir=`expr $a : '\(.*\).tar.gz'`
    mkdir /usr/share/nginx/html/$a_dir 2>/dev/null
    tar xvf $a -C /usr/share/nginx/html/$a_dir
done

