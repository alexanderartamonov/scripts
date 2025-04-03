import json
import boto3
import os
import sys
from botocore.exceptions import ClientError
data = [json.loads(line) for line in open('inventory/i-d4d93b55.json', 'r')]
# Output: {'name': 'Bob', 'languages': ['English', 'French']}
# print(data)

for item in data:
    if item.get('Status') in ('Running') and item.get('Name') in ('AmazonSSMAgent'):
       output =  print(item['Name']+'='+item['Status']) 
       print ('AmazonSSMAgent is up and running')
    # else:
    #    print(item.get('Name')+'='+item.get('Status'))

# for item2 in data:
#     if item2.get('Status') in ('Running') and item2.get('Name') in ('Zabbix Agent'):
#        output2 =  print(item2['Name']+'='+item2['Status']) 
#        print ('AmazonSSMAgent is up and running')
#     else:
#         output3 =  print(item2['Name']+'='+item2['Status']) 


message = {"hello": "Tun"}
client = boto3.client('sns')
response = client.publish(
    TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
    Message=json.dumps({'default': json.dumps(message)}),
    MessageStructure='json'
)