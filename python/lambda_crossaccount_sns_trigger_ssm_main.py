import ipaddress
import json
import boto3
import os
import time

THREEDS_UAT_ROLE_ARN = os.environ['AWS_3DSUAT_IAM_CROSS_ACCOUNT_ROLE']
AWS_SECRET_ARN = os.environ['AWS_SECRETS_MANAGER_ARN']

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

    
def lambda_handler(event, context):
    session_threeds_uat_assumed = aws_session(role_arn=THREEDS_UAT_ROLE_ARN, session_name='threeds_uat_session')
    session_regular = aws_session()
    threeds_uat_account_id = session_threeds_uat_assumed.client('sts').get_caller_identity()['Account']
    uat_account_id = session_regular.client('sts').get_caller_identity()['Account']
    print(threeds_uat_account_id)
    print(uat_account_id)
    print(event)
  # Check if the event is an SNS message
    if 'Records' in event and isinstance(event['Records'], list):
        for record in event['Records']:
            if 'Sns' in record and 'Message' in record['Sns']:
                sns_message = json.loads(record['Sns']['Message'])
                json_string = json.dumps(sns_message)
                arr_zabbix_messages = [] 
                arr_zabbix_messages.append("Disk space is low")
                arr_zabbix_messages.append("Disk space is critically low")
                arr_zabbix_messages.append("Memory usage is high")
                arr_zabbix_messages.append("Something else")
                sns_message_name = sns_message.get('Name')
                sns_message_ip = sns_message.get('IPAddress')
                sns_message_type = sns_message.get('Zabbix_type')
                print("name: "+sns_message_name)
                print("ip-address: "+sns_message_ip)
                print("message-type : "+sns_message_type)
                print("getting secret manager values..")
                secrets_client = boto3.client('secretsmanager')
                get_secret_value_response = secrets_client.get_secret_value(SecretId=AWS_SECRET_ARN)
                secret_value = json.loads(get_secret_value_response['SecretString'])
                # Access secret manager values
                uat_cidr = secret_value['uat']['CIDR']
                uat_aws_account_id = secret_value['uat']['AwsAccountId']
                uat_s3_bucket_name = secret_value['uat']['S3bucketName']
                threedsuat_cidr = secret_value['3dsuat']['CIDR']
                threedsuat_aws_account_id = secret_value['3dsuat']['AwsAccountId']
                threedsuat_s3_bucket_name = secret_value['3dsuat']['S3bucketName']
                print("ip-address: "+sns_message_ip)
                print("UAT CIDR:", uat_cidr)
                print("UAT AWS Account ID:", uat_aws_account_id)
                print("UAT S3 Bucket Name:", uat_s3_bucket_name)
                print("3DSUAT CIDR:", threedsuat_cidr)
                print("3DSUAT AWS Account ID:", threedsuat_aws_account_id)
                print("3DSUAT S3 Bucket Name:", threedsuat_s3_bucket_name)
                if ipaddress.ip_address(sns_message_ip) in ipaddress.ip_network(uat_cidr[0]) or ipaddress.ip_address(sns_message_ip) in ipaddress.ip_network(uat_cidr[1]):
                    print("ip address "+sns_message_ip+" belongs to ",uat_cidr," CIDRs")
                    print("trying to get instance id by ip address from sns payload: "+sns_message_ip)
                    ec2_uat_client = session_regular.client('ec2')
                    ec2_get_ip_response = ec2_uat_client.describe_instances(
                            Filters=[{
                                      'Name': 'network-interface.addresses.private-ip-address', 'Values':[sns_message_ip]
                                }
                            ]
                    )
                    print(ec2_get_ip_response)
                    instance_id = ec2_get_ip_response['Reservations'][0]['Instances'][0]['InstanceId']
                    print("got instance id: " +instance_id) 
                    if arr_zabbix_messages[0] in json_string or arr_zabbix_messages[1] in json_string and sns_message_type == 'Problem':
                        print(f"The target string '"+sns_message_name+"' is present in the SNS payload.")
                        try:
                            ssm_uat_client = session_regular.client('ssm')
                            ssm_response = ssm_uat_client.send_command(
                            InstanceIds=[instance_id],
                            DocumentName='uat-chaos-engineering-disk-usage',
                            DocumentVersion= '1',
                            )
                            print(f"SSM Command sent successfully. Command ID: {ssm_response['Command']['CommandId']}")
                            return {
                                'statusCode': 200,
                                'body': json.dumps('SSM Command sent successfully')
                            }
                        except Exception as e:
                            print(f"Error sending SSM command: {e}")
                            return {
                                'statusCode': 500,
                                'body': json.dumps('Error sending SSM command')
                            }
                    else:
                        print(f"Could not find any messages in the SNS payload.")
                elif ipaddress.ip_address(sns_message_ip) in ipaddress.ip_network(threedsuat_cidr[0]) or ipaddress.ip_address(sns_message_ip) in ipaddress.ip_network(threedsuat_cidr[1]):
                    print("ip address "+sns_message_ip+" belongs to ",threedsuat_cidr," CIDRs")
                    print("trying to get instance id by ip address from sns payload: "+sns_message_ip)
                    ec2_3ds_uat_client = session_threeds_uat_assumed.client('ec2')
                    ec2_get_ip_response = ec2_3ds_uat_client.describe_instances(
                            Filters=[{
                                      'Name': 'network-interface.addresses.private-ip-address', 'Values':[sns_message_ip]
                                }
                            ]
                    )
                    print(ec2_get_ip_response)
                    instance_id = ec2_get_ip_response['Reservations'][0]['Instances'][0]['InstanceId']
                    print("got instance id: " +instance_id) 
                    if arr_zabbix_messages[0] in json_string or arr_zabbix_messages[1] in json_string and sns_message_type == 'Problem':
                        print(f"The target string '"+sns_message_name+"' is present in the SNS payload.")
                        try:
                            ssm_3ds_uat_client = session_threeds_uat_assumed.client('ssm')
                            ssm_response = ssm_3ds_uat_client.send_command(
                            InstanceIds=[instance_id],
                            DocumentName='3dsuat-chaos-engineering-disk-usage',
                            DocumentVersion= '1',
                            )
                            print(f"SSM Command sent successfully. Command ID: {ssm_response['Command']['CommandId']}")
                            return {
                                'statusCode': 200,
                                'body': json.dumps('SSM Command sent successfully')
                            }
                        except Exception as e:
                            print(f"Error sending SSM command: {e}")
                            return {
                                'statusCode': 500,
                                'body': json.dumps('Error sending SSM command')
                            }
                    else:
                        print("No SNS message or missing expected values in the message.")
                        return {
                            'statusCode': 200,
                            'body': json.dumps('No SNS message or missing expected values')
                        }
                else:
                    print("this ip address "+sns_message_ip+"did not match any of provided IP CIDRs")