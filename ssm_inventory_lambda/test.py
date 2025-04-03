#!/usr/bin/python3
import io, os, sys
import boto3
import logging,traceback
import json
import re
from types import SimpleNamespace
from botocore.exceptions import ClientError



s3 = boto3.resource("s3")
sns_client = boto3.client('sns')

s3_bucket = '2c2p-uat-ssm-inventory'
bucket = s3.Bucket(s3_bucket)
s3_path = 'AWS:Service/accountid=891349355538/region=ap-southeast-1/resourcetype=ManagedInstanceInventory/'

#returns content of s3 subfolder with filter
s3_files = bucket.objects.filter(Prefix=s3_path)
def main():
    datalst =[]
    programisnotexists =[]
    lst_name = 'Amazon SSM Agent,Zabbix Agent'
    for s3_file in s3_files:
            key = s3_file.key
            body = s3_file.get()['Body'].read().decode()
            data = json.dumps(body) #dumps return json object as a string
            result_json = json.loads(data)
            print(result_json)
            instanceid = getattr(person, 'name')
            # list = s3_file.key.split('.', 4)[0]
            # instance_id = list.rsplit('/')[4] #get instance id from s3 path
#             programlst = ['Amazon SSM Agent','Zabbix Agent']
#             for item in result_json.split("\n"):
#                 if  item['DisplayName'] == 'Amazon SSM Agent' or  item['DisplayName'] == 'Zabbix Agent':
#                     programlst.remove(item['DisplayName'])           
#                 if check_if_existsrulename(result_json['DisplayName'],lst_name):
#                     if item['Status'] == 'Stopped':
#                         datalst.append(item['Status']+"|"+item['DisplayName']+"|"+instance_id)
#     for u in programlst:
#         programisnotexists.append("not install"+"|"+u+"|"+instance_id)

#     for x in datalst and programisnotexists:
#         response = sns_client.publish(
#         TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
#         Subject='Report from Amazon SSM Inventory for instance ' + instance_id,
#         Message=x,
#         MessageStructure='string')
    

# def check_if_existsrulename(name, listofname):
#     for n in listofname.split(',') :
#         # print(n.strip())
#         if name.casefold() == n.strip().casefold():
#         #    print(name+" True")
#             return True
    
#     # print(name+" False")
#     return False


if __name__ == "__main__":
    main()