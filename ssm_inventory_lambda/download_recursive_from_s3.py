import os
import errno
import boto3
import json
import re

client = boto3.client('s3')
sns_client = boto3.client('sns')

Path = "./inventory/"
filelist = os.listdir(Path)
samples = []

def assert_dir_exists(path):
    try:
        os.makedirs(path)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise


def download_dir(bucket, path, target):
    # Handle missing / at end of prefix
    if not path.endswith('/'):
        path += '/'

    paginator = client.get_paginator('list_objects_v2')
    for result in paginator.paginate(Bucket=bucket, Prefix=path):
        # Download each file individually
        for key in result['Contents']:
            # Calculate relative path
            rel_path = key['Key'][len(path):]
            # Skip paths ending in /
            if not key['Key'].endswith('/'):
                local_file_path = os.path.join(target, rel_path)
                # Make sure directories exist
                local_file_dir = os.path.dirname(local_file_path)
                assert_dir_exists(local_file_dir)
                client.download_file(bucket, key['Key'], local_file_path)

def check_files(Path):
    for i in filelist:
        if i.endswith(".json"):  # You could also add "and i.startswith('f')
            instance_id = i.split('.', 4)[0]
            with open(Path + i, 'r') as f:
                for line in f.readlines():
                    #Here you can check (with regex, if, or whatever if the keyword is in the document.)
                    if "Zabbix Agent" in line and "Stopped" in line:
                        print ("Required service is stopped for %s instance!" % (instance_id))
                        output = line
                        response = sns_client.publish(
                        TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
                        Subject='Report from Amazon SSM Inventory for instance ' + instance_id,
                        Message=output,
                        MessageStructure='string')
                    elif "Amazon SSM Agent" in line and "Stopped" in line:
                        print ("Required service is stopped for %s instance!" % (instance_id))
                        output = line
                        response = sns_client.publish(
                        TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
                        Subject='Report from Amazon SSM Inventory for instance ' + instance_id,
                        Message=output,
                        MessageStructure='string')
                    
                        
           
                        

download_dir('2c2p-uat-ssm-inventory', 'AWS:Service/accountid=891349355538/region=ap-southeast-1/resourcetype=ManagedInstanceInventory/', './inventory')          
check_files("./inventory/")
        