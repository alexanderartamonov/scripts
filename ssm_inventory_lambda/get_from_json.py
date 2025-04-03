#!/usr/bin/python3
import io, os, sys
from array import array
import boto3
import logging,traceback
import json
import re
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

for obj in prefix_objs:
        key = obj.key
        body = obj.get()['Body'].read().decode('utf-8')
        data = json.dumps(body) #dumps return json object as a string
        result_json = json.loads(data)  
        list = obj.key.split('.', 4)[0]
        instance_id = list.rsplit('/')[4] #get instance id from s3 path
        for item in result_json.split("\n"):
            if "Zabbix Agent" in item and "Stopped" in item:
                print ("Required service is stopped for %s instance!" % (instance_id))
                output = item
                response = sns_client.publish(
                TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
                Subject='Report from Amazon SSM Inventory for instance ' + instance_id,
                Message=output,
                MessageStructure='string')
            elif "Amazon SSM Agent" in item and "Stopped" in item:
                print ("Required service is stopped for %s instance!" % (instance_id))
                output = item
                response = sns_client.publish(
                TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
                Subject='Report from Amazon SSM Inventory for instance ' + instance_id,
                Message=output,
                MessageStructure='string')