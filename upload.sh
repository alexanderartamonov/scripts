#!/bin/bash
TOKEN=token-value
for file in /some/dir/*
do
 curl -H "X-JFrog-Art-Api: $TOKEN" -T $file http://remote.server.com/remote/file/url
done
