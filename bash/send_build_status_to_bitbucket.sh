#!/bin/bash

#disable this step
if [ 1 == 2 ] 
then
  curl ${linked_url}/api/json -u bot:P@ssw0rd -o result.json
  
  export result=`jq ".result" result.json`
  
  jq -rc ".actions[]" result.json | while read -r
  do
          if [ `echo $REPLY | jq "._class"` == "\"hudson.tasks.junit.TestResultAction\"" ]
          then
                  export fail=`echo $REPLY | jq ".failCount"`
                  export skip=`echo $REPLY | jq ".skipCount"`
                  export total=`echo $REPLY | jq ".totalCount"`
          fi
  done
  
  if [ $result == "\"SUCCESS\"" ]
  then
          export state=SUCCESSFUL
          export description="Success"
  else
          export state=FAILED
          export description="${fail} of ${total} tests fail"
  fi
  
  echo "result : ${result}"
  echo "state : ${state}"
  echo "fail : ${fail}"
  echo "skip : ${skip}"
  echo "description : ${description}"
  echo "commit : ${commit}"
  echo "curl command : "
  echo curl -d '{"state":"'"${state}"'","key":"'"${key}"'","name":"'"${name}"'","url":"'"${linked_url}"'","description":"'"${description}"'"}' https://scm.2c2p.com/rest/build-status/1.0/commits/${commit} -H "Accept: */*" -H "Content-Type: application/json" -u qa_jenkins:2c2pP@ssw0rdQA
  curl -d '{"state":"'"${state}"'","key":"'"${key}"'","name":"'"${name}"'","url":"'"${linked_url}"'","description":"'"${description}"'"}' https://scm.2c2p.com/rest/build-status/1.0/commits/${commit} -H "Accept: */*" -H "Content-Type: application/json" -u qa_jenkins:2c2pP@ssw0rdQA
fi