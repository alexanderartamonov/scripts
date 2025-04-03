import json
import boto3
import os
import time


THREEDS_UAT_ROLE_ARN = 'arn:aws:iam::089465505731:role/CloudWatchMonitoring'

def aws_session(role_arn=None, session_name='threeds_uat_session'):
    """
    If role_arn is given assumes a role and returns boto3 session
    otherwise return a regular session with the current IAM user/role
    """
    if role_arn:
        client = boto3.client('sts')
        response = client.assume_role(RoleArn=role_arn, RoleSessionName=session_name)
        session = boto3.Session(
            aws_access_key_id=response['Credentials']['AccessKeyId'],
            aws_secret_access_key=response['Credentials']['SecretAccessKey'],
            aws_session_token=response['Credentials']['SessionToken'],
            region_name='ap-southeast-1')
        return session
    else:
        return boto3.Session()

    
def handler(event, context):
    session_threeds_uat_assumed = aws_session(role_arn=THREEDS_UAT_ROLE_ARN, session_name='threeds_uat_session')
    session_regular = aws_session()
    threeds_uat_account_id = session_threeds_uat_assumed.client('sts').get_caller_identity()['Account']
    uat_account_id = session_regular.client('sts').get_caller_identity()['Account']
    print(threeds_uat_account_id)
    print(uat_account_id)
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
                
                print("trying to get instance id from ip address from sns payload: "+sns_message_ip)
                ec2_3ds_uat_client = session_threeds_uat_assumed.client('ec2')
                ec2_get_ip_response = ec2_3ds_uat_client.describe_instances(
                        Filters=[{
                                  'Name': 'network-interface.addresses.private-ip-address', 'Values':[sns_message_ip]
                            }
                        ]
                )
                print(ec2_get_ip_response)
                instance_id = ec2_get_ip_response['Reservations'][0]['Instances'][0]['InstanceId']
                print("instance_id: " +instance_id) 
                
                if arr_zabbix_messages[0] in json_string and sns_message_type == 'Problem':
                    print(f"The target string "+arr_zabbix_messages[0]+" is present in the SNS payload.")
                    ssm_3ds_uat_client = session_threeds_uat_assumed.client('ssm')
                    ssm_response = ssm_3ds_uat_client.send_command(
                    InstanceIds=[instance_id],
                    DocumentName='3dsuat-chaos-engineering-disk-usage',
                    DocumentVersion= '1',
                    )
                    ssm_command_id = ssm_response['Command']['CommandId']
                    output = ''
                elif arr_zabbix_messages[1] in json_string:
                    print(f"The target string "+arr_zabbix_messages[1]+" is present in the SNS payload.")
                else:
                    print(f"Could not find any messages in the SNS payload.")
                
                while True:
                    try:
                        time.sleep(0.5)  # some delay always required...
                        ssm_result = ssm_3ds_uat_client.get_command_invocation(
                            CommandId=ssm_command_id,
                            InstanceId=instance_id,
                        )
                        if ssm_result['Status'] == 'Success':
                            return {
                                'statusCode': 200,
                                'body': json.dumps(ssm_result, sort_keys=True, indent=2)
                            } 
                        elif ssm_result['Status'] == 'Failed':
                            output += ssm_result['StandardErrorContent']
                            return {
                                'statusCode': json.dumps(ssm_result['HTTPStatusCode']),
                                'body': json.dumps(ssm_result, sort_keys=True, indent=2)
                            } 
                        else:
                            output += ssm_result['StandardOutputContent']
                            # Print the command output
                            print(output)
                    except ssm_3ds_uat_client.exceptions.InvocationDoesNotExist:
                        continue

                    