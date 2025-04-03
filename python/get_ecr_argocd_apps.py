import requests as reqs
import logging as logger
import boto3
from base64 import b64decode
import csv
from prettytable import PrettyTable
from colorama import init, Fore, Style


# Initialize colorama
init()

# Set up logger
logger.basicConfig(level=logger.INFO, format='%(levelname)s: %(message)s')

# ArgoCD server information
argocd_server = 'https://emv3ds-prod-argocd.2c2p.com/'
username = 'admin'
password = 'h6uaD5U9VRWYgjpZ'

# AWS ECR information
aws_account_id = ''
aws_region = 'ap-southeast-1'
aws_profile = '2c2p3dsprodsso'
dev = boto3.session.Session(profile_name='2c2p3dsprodsso')
# Login to ArgoCD API
def login(argocd_server, username, password):
    response = reqs.post(
        f'{argocd_server}/api/v1/session',
        json={"username": username, "password": password},
    )
    if response.status_code == 200:
        logger.debug("ArgoCD login response: %s", response.json())
        return response.json()['token']
    else:
        logger.error("ArgoCD login failed with status code: %s and response: %s", response.status_code, response.text)
        raise Exception("Failed to login to ArgoCD API")

# Get list of applications
def get_applications(token):
    headers = {'Authorization': f'Bearer {token}'}
    response = reqs.get(f'{argocd_server}/api/v1/applications', headers=headers)
    if response.status_code == 200:
        logger.debug("ArgoCD applications response: %s", response.json())
        return response.json()['items']
    else:
        logger.error("Failed to fetch applications with status code: %s and response: %s", response.status_code, response.text)
        raise Exception("Failed to fetch list of applications")

# Get AWS ECR authorization token
def get_ecr_auth_token():
    ecr_client = boto3.client('ecr', region_name=aws_region)
    response = ecr_client.get_authorization_token()
    logger.debug("ECR authorization token response: %s", response)
    if 'authorizationData' in response:
        auth_data = response['authorizationData'][0]
        auth_token = b64decode(auth_data['authorizationToken']).decode('utf-8').split(':')[1]
        return auth_token
    else:
        raise Exception("Failed to get AWS ECR authorization token")

# Get latest image tag from AWS ECR
def get_latest_ecr_image_tag(repository, auth_token):
    ecr_client = boto3.client('ecr', region_name=aws_region)
    response = ecr_client.describe_images(
        repositoryName=repository,
        filter={'tagStatus': 'TAGGED'}
    )
    logger.debug("ECR describe images response for repository %s: %s", repository, response)
    if 'imageDetails' in response and response['imageDetails']:
        # Sort images by push date to get the latest tag
        image_details = sorted(response['imageDetails'], key=lambda x: x['imagePushedAt'], reverse=True)
        latest_image = image_details[0]
        latest_image_tag = latest_image['imageTags'][0]
        logger.debug("Latest image tag for repository %s: %s", repository, latest_image_tag)
        return latest_image_tag
    else:
        raise Exception(f"Failed to fetch latest AWS ECR image tag for repository {repository}")

if __name__ == "__main__":
    try:
        # Login to ArgoCD
        token = login(argocd_server, username, password)
        logger.info("Successfully logged in to ArgoCD.")

        # Get list of applications
        applications = get_applications(token)
        logger.info("Successfully fetched list of applications.")

        # Get AWS ECR authorization token
        auth_token = get_ecr_auth_token()
        logger.info("Successfully retrieved AWS ECR authorization token.")

        # Export the data to CSV
        with open('image_comparison.csv', 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["Application", "Repository", "Deployed Image", "Latest Image Tag", "Match"])

            # Iterate over each application
            for app in applications:
                app_name = app['metadata']['name']
                if 'status' in app and 'summary' in app['status'] and 'images' in app['status']['summary']:
                    images = app['status']['summary']['images']
                    for image in images:
                        # Extract repository name from the image URL
                        repository = image.split('/')[1].split(':')[0]
                        deployed_image_tag = image.split(':')[-1]
                        logger.info("Processing application: %s, repository: %s, deployed image tag: %s", app_name, repository, deployed_image_tag)
                        try:
                            # Get the latest image tag from AWS ECR
                            latest_ecr_image_tag = get_latest_ecr_image_tag(repository, auth_token)
                            # Compare the deployed image tag with the latest image tag from AWS ECR
                            match_status = "Match" if deployed_image_tag == latest_ecr_image_tag else "Mismatch"

                            # Write the data to CSV
                            writer.writerow([app_name, repository, deployed_image_tag, latest_ecr_image_tag,  match_status])
                        except Exception as e:
                            logger.error("Error processing repository %s for application %s: %s", repository, app_name, str(e))
                else:
                    logger.info(f"No image information found for application {app_name}.")

        logger.info("Data exported to image_comparison.csv successfully.")

    except Exception as e:
        logger.error("Error: %s", str(e))