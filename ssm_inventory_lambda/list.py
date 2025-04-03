import json
import os
import errno
import boto3
import re
import sys

sns_client = boto3.client('sns')

Path = "./inventory/"
filelist = os.listdir(Path)

def main():
  datalstexist =[]
  lst_name = 'Zabbix Agent,Amazon SSM Agent'   
  for i in filelist:
        # datacount=0
        if i.endswith(".json"):  # You could also add "and i.startswith('f')
            instance_id = i.split('.', 4)[0]
            with open(Path + i, 'r') as f:
                duplicates = []
                for line in f:  
                    data = json.loads(line)
                    list(set(data))
                    #if data['DisplayName'] == 'Windows Update' or data['DisplayName'] == 'Windows Search':
                    if check_if_existsrulename(data['DisplayName'],lst_name):    
                        # datacount=datacount+1
                        if data['Status'] == 'Stopped':
                           datalstexist.append(data['Status']+"|"+data['DisplayName']+"|"+data['resourceId'])
                    if line not in duplicates:
                        datalstexist.append(data['Status']+"|"+data['DisplayName']+"|"+data['resourceId'])
                        

#   print(str(datacount)+"|"+str(instance_id))
                    # if check_if_existsrulename(data['DisplayName'],lst_name) == False: 
                    #         print(lst_name+ ' does not exist'+' for instance '+ instance_id)
                        #   print(data['Status']+"|"+data['DisplayName'])
                        # print ("Number of items in the list = ", len(datalst))
  for x in datalstexist:
    print(x)
#   for y in datalstnotexist:
#     print(y)
    # response = sns_client.publish(
    # TargetArn='arn:aws:sns:ap-southeast-1:891349355538:Test_Mail_Alert',
    # Subject='Report from Amazon SSM Inventory for instance ' + instance_id,
    # Message=x,
    # MessageStructure='string')

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


