import json
import base64
import requests
import boto3
import logging
from botocore.exceptions import BotoCoreError, ClientError

# Configure Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# API Endpoint and Headers
API_URL = "https://bc1yy8dzsg.execute-api.eu-west-1.amazonaws.com/v1/data"
HEADERS = {
    "X-Siemens-Auth": "test",
    "Content-Type": "application/json"
}

def get_private_subnet_id():
    """
    Fetches the private subnet ID from EC2 metadata.
    """
    ec2 = boto3.client("ec2", region_name="ap-south-1")
    try:
        response = ec2.describe_subnets(
            Filters=[{"Name": "tag:Name", "Values": ["private-subnet"]}]
        )
        return response["Subnets"][0]["SubnetId"]
    except (BotoCoreError, ClientError) as e:
        logger.error(f"Error fetching subnet ID: {e}")
        return None

def lambda_handler(event, context):
    """
    AWS Lambda function to send a POST request to the given API.
    """
    private_subnet_id = get_private_subnet_id()
    if not private_subnet_id:
        return {"statusCode": 500, "body": "Failed to retrieve subnet ID"}

    # Payload with real details
    payload = {
        "subnet_id": private_subnet_id,
        "name": "Snehal Laxman Pawar",
        "email": "snehallpawar11@gmail.com"
    }

    try:
        response = requests.post(API_URL, headers=HEADERS, json=payload)
        response_data = response.json()
        
        logger.info(f"API Response: {response_data}")

        return {
            "statusCode": response.status_code,
            "body": json.dumps(response_data)
        }
    except requests.exceptions.RequestException as e:
        logger.error(f"Request failed: {e}")
        return {"statusCode": 500, "body": "Request failed"}
