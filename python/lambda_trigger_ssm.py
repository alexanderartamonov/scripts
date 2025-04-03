import os
import boto3
import botocore
import time
import json


def handler(event=None, context=None):
    client = boto3.client('ssm')
    instance_id = os.environ['INSTANCE_ID'] # hard-code for example
    ssm_document_version = os.environ['SSM_DISK_USAGE_PROVOKE_DOCUMENT_VERSION']
    response = client.send_command(
        InstanceIds=[instance_id],
        # Parameters={
        #     'commands': [
        #         'Invoke-Command  -ScriptBlock { $env:COMPUTERNAME;  Get-Date }'
        #     ]
        # }
        DocumentName='uat-chaos-engineering-disk-usage-provoke',
        DocumentVersion=ssm_document_version,
    )
    command_id = response['Command']['CommandId']
    tries = 0
    output = 'False'
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
                    # 'body': json.dumps('AWSRunCommand executed with status '+result['Status']+' on instance '+result['InstanceId']+' Http result code: '+str(result['ResponseMetadata']['HTTPStatusCode']),sort_keys=True, indent=4)
                    'body': json.dumps(result, sort_keys=True, indent=2)
                } 
            elif result['Status'] == 'Failed':
                return {
                    'statusCode': json.dumps(result['HTTPStatusCode']),
                    # 'body': json.dumps('AWSRunCommand executed with status '+result['Status']+' on instance '+result['InstanceId']+' Http result code: '+str(result['ResponseMetadata']['HTTPStatusCode']),sort_keys=True, indent=4)
                    'body': json.dumps(result, sort_keys=True, indent=2)
                } 
            output = result['Status']
            break
        except client.exceptions.InvocationDoesNotExist:
            continue

    return output