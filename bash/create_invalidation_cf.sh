#!/bin/bash
set -x
echo "Create CloudFront invalidation"
cfids=$(aws cloudfront list-distributions --query "DistributionList.Items[*].{id:Id,origin_domain:Origins.Items[0].DomainName}[?starts_with(origin_domain,'sit-v4ui')].id" --output text)
cfid=$(echo $cfids head -n1   | awk '{print $1;}')
get_invalidation() {
echo $cfid
}
get_invalidation
INVALIDATION_ID=$(aws cloudfront create-invalidation --distribution-id $cfid --paths "/*" | jq -r '.Invalidation.Id')
wait_for_invalidation() {
    while [ $(aws cloudfront get-invalidation --id $INVALIDATION_ID --distribution-id $cfid | jq -r '.Invalidation.Status') != "Completed" ]
    do
    aws cloudfront wait invalidation-completed --distribution-id $cfid --id $INVALIDATION_ID                       
    done
    echo "Done Invalidation Cache";  
}
wait_for_invalidation
aws cloudfront wait distribution-deployed --id $cfid
