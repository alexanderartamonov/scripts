from __future__ import print_function
import json
import boto3
import os
import time
print('Loading function')

def handler(event, context):
  # Check if the event is an SNS message
    if 'Records' in event and isinstance(event['Records'], list):
        for record in event['Records']:
            if 'Sns' in record and 'Message' in record['Sns']:
                sns_message = json.loads(record['Sns']['Message'])
                json_string = json.dumps(sns_message)
                arr_zabbix_messages = [] 
                arr_zabbix_messages.append("Disk space is critically low")
                arr_zabbix_messages.append("Memory usage is high")
                arr_zabbix_messages.append("Something else")
                sns_message_name = sns_message.get('Name')
                sns_message_ip = sns_message.get('IPAddress')
                sns_message_type = sns_message.get('Zabbix_type')
                print("name: "+sns_message_name)
                print("ip-address: "+sns_message_ip)
                print("message-type : "+sns_message_type)

                ec2_client = boto3.client('ec2')
                private_ip = sns_message_ip
                response = ec2_client.describe_instances(
                        Filters=[{
                                  'Name': 'network-interface.addresses.private-ip-address', 'Values':[private_ip]
                            }
                        ]
                    )
                instance_id = response['Reservations'][0]['Instances'][0]['InstanceId']
                print(instance_id) 
                client = boto3.client('ssm')
                if arr_zabbix_messages[0] in json_string and sns_message_type == 'Problem':
                    print(f"The target string "+arr_zabbix_messages[0]+" is present in the SNS payload.")
                    response = client.send_command(
                    InstanceIds=[instance_id],
                    DocumentName='uat-chaos-engineering-disk-usage',
                    DocumentVersion= os.environ['SSM_DISK_USAGE_DOCUMENT_VERSION'],
                    )
                    command_id = response['Command']['CommandId']
                elif arr_zabbix_messages[1] in json_string:
                    print(f"The target string "+arr_zabbix_messages[1]+" is present in the SNS payload.")
                else:
                    print(f"Could not find any messages in the SNS payload.")
                tries = 0
                while tries < 20:
                    tries = tries + 1
                    try:
                        time.sleep(1)  # some delay always required...
                        result = client.get_command_invocation(
                            CommandId=command_id,
                            InstanceId=instance_id,
                        )
                        print(result)
                        if result['Status'] == 'InProgress':
                            continue
                        elif result['Status'] == 'Success':
                            return {
                                'statusCode': 200,
                                'body': json.dumps(result, sort_keys=True, indent=2)
                            } 
                        elif result['Status'] == 'Failed':
                            return {
                                'statusCode': json.dumps(result['HTTPStatusCode']),
                                'body': json.dumps(result, sort_keys=True, indent=2)
                            } 
                        output = result['Status']
                        break
                    except client.exceptions.InvocationDoesNotExist:
                        continue

                return output