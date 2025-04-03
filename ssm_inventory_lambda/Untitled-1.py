#!/usr/bin/python3
import io, os, sys
from array import array
import boto3
import re
import logging,traceback
import json
from types import SimpleNamespace
from botocore.exceptions import ClientError


s3_client = boto3.client('s3')
s3 = boto3.resource("s3")
sns_client = boto3.client('sns')

s3_bucket = '2c2p-uat-ssm-inventory'
bucket = s3.Bucket(s3_bucket)
s3_path = 'AWS:Service/accountid=891349355538/region=ap-southeast-1/resourcetype=ManagedInstanceInventory/'


#returns content of s3 subfolder with filter
prefix_objs = bucket.objects.filter(Prefix=s3_path)
res = []
# keys = "".join(list(prefix_objs.keys()))
# values = "".join(list(prefix_objs.values()))
# print(keys,values)

for obj in prefix_objs:
        key = obj.key
        body = obj.get()['Body'].read().decode('utf-8')
        # print(body)
        results = []
        data = json.dumps(body) #dumps return json object as a string
        old_result_json = json.loads(data)  
        list = obj.key.split('.', 4)[0]
        instance_id = list.rsplit('/')[4] #get instance id from s3 path
        # for line in data.readlines():
        #     if re.search (r'[]', line):
        #         #  results.append(line)
        #         print (results.append(line))
        for item in old_result_json:
            if "Zabbix Agent" in item and "Stopped" in item:
                output = item
                # print(output.split("\n"))
                response = sns_client.publish(
                TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
                Subject='Report from Amazon SSM Inventory for instance ' + instance_id,
                Message=output,
                MessageStructure='string')
            # elif "Zabbix Agent" in item and "Stopped" in item:
            #     response = sns_client.publish(
            #     TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
            #     Subject='Report from Amazon SSM Inventory for instance ' + instance_id,
            #     Message=output,
            #     MessageStructure='string')
            # elif "Zabbix Agent" not in item:
            #     print('Zabbix Agent is missing for ' + instance_id)
            #     response = sns_client.publish(
            #     TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
            #     Subject='Zabbix Agent is missing',
            #     Message='Zabbix Agent is missing for instance ' + instance_id,
            #     MessageStructure='string')