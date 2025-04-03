import json
import boto3
s3_obj = boto3.client('s3')

s3_clientobj = s3_obj.get_object(Bucket='2c2p-uat-ssm-inventory', Key='AWS:Service/accountid=891349355538/region=ap-southeast-1/resourcetype=ManagedInstanceInventory/i-0a0dc88f8ac85261b.json')
s3_clientdata = s3_clientobj['Body'].read().decode('utf-8')

print("printing s3_clientdata")
print(s3_clientdata)
print(type(s3_clientdata))


s3clientlist=json.loads(s3_clientdata)
print("json loaded data")
print(s3clientlist)
print(type(s3clientlist))

#print(s3clientlist[0]['clientName'])

loclientdict=next(item for item in s3clientlist if item["clientID"] == "22oi5qjafaflklkjklajlf")
print(loclientdict)
group=loclientdict.get('group')
print(group)