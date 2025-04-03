import os
import errno
import boto3
import json
import re


client = boto3.client('s3')
sns_client = boto3.client('sns')

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


download_dir('2c2p-uat-ssm-inventory', 'AWS:Service/accountid=891349355538/region=ap-southeast-1/resourcetype=ManagedInstanceInventory/', './inventory')  

def main():
  datalst =[]
  programisnotexists =[]
  lst_name = 'Amazon SSM Agent,Zabbix Agent'
  path = "./inventory/"
  dir_list = os.listdir(path)
  for f in dir_list:
      instanceid = f.replace('.json','')
      programlst = ['Amazon SSM Agent']
      with open(path+"/"+f) as ff:
       for line in ff:
            data = json.loads(line)
            if  data['DisplayName'] == 'Amazon SSM Agent' or  data['DisplayName'] == 'Zabbix Agent':
                programlst.remove(data['DisplayName'])           
            if check_if_existsrulename(data['DisplayName'],lst_name):
                if data['Status'] == 'Stopped':
                   datalst.append("Service"+" - "+ data['DisplayName']+ " is "+ data['Status']+" for "+data['resourceId'])
       for u in programlst:
            programisnotexists.append(u+" is not installed"+" for "+data['resourceId'])

  for x in datalst and programisnotexists:
    response = sns_client.publish(
    TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
    Subject='Report from Amazon SSM Inventory',
    Message=x,
    MessageStructure='string')
    

def check_if_existsrulename(name, listofname):
    for n in listofname.split(',') :
        # print(n.strip())
        if name.casefold() == n.strip().casefold():
        #    print(name+" True")
           return True
    
    # print(name+" False")
    return False



if __name__ == "__main__":
    main()


