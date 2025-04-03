import boto3
import json
import logging
import time
import os

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
ssm_client = boto3.client("ssm")
EC2_KEY = os.environ['INSTANCE_ID']
DOCUMENT_NAME = 'uat-chaos-engineering-memory-peak-get'
DOCUMENT_VERSION = os.environ['SSM_MEMORY_PEAK_GET_DOCUMENT_VERSION']
def check_response(response_json):
    try:
        if response_json['ResponseMetadata']['HTTPStatusCode'] == 200:
            return {
                'body': json.dumps(result, sort_keys=True, indent=2)
            }
        else:
            return False
    except KeyError:
        return False



def send_command(instance_id):
    # Until the document is not ready, waits in accordance to a backoff mechanism.
    try:
        response = ssm_client.send_command(
            InstanceIds = [ instance_id ], 
            DocumentName=DOCUMENT_NAME,
            DocumentVersion=DOCUMENT_VERSION,
            TimeoutSeconds= 600
            )
        if check_response(response):
            logger.info("Command sent: %s", response)
            print(response['Command']['CommandId'])
            return response['Command']['CommandId']
        else:
            logger.error("Command could not be sent: %s", response)
            return None
    except Exception as e:
        logger.error("Command could not be sent: %s", str(e))
        return None

def check_command(command_id, instance_id):
    timewait = 1
    while True:
        time.sleep(10)
        response_iterator = ssm_client.list_command_invocations(
            CommandId = command_id, 
            InstanceId = instance_id, 
            Details=False
            )
        logging.info( "list command invocations: %s", response_iterator)
            
        if check_response(response_iterator):
            response_iterator_status = response_iterator['CommandInvocations'][0]['Status']
            if response_iterator_status != 'Pending':
                if response_iterator_status == 'InProgress' or response_iterator_status == 'Success':
                    logging.info( "Status: %s", response_iterator_status)
                    return True
                else:
                    logging.error("ERROR: status: %s", response_iterator)
                    return False
        time.sleep(timewait)
        timewait += timewait


def handler(event, context):
    try:
        command_id = send_command(EC2_KEY)
        print (command_id)
        if command_id != None:
            if check_command(command_id, EC2_KEY):
                logging.info("Lambda executed correctly")
    except Exception as e:
        logging.error("Error: %s", str(e))
