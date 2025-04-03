#!/bin/bash

cfids=$(aws cloudfront list-distributions --query "DistributionList.Items[*].{id:Id,origin_domain:Origins.Items[0].DomainName}[?starts_with(origin_domain,'pgw-uitemplate-admin-portal-uatf')].id" --output text)
cfid=$(echo $cfids head -n1   | awk '{print $1;}')
echo $cfid
aws cloudfront create-invalidation --distribution-id $cfid --paths "/*"
