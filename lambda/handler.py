import boto3
import os
import json

def lambda_handler(event, context):
    secret_name = os.environ.get("SECRET_NAME")
    client = boto3.client("secretsmanager")

    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])
        return {
            "statusCode": 200,
            "body": f"Retrieved secret: {secret['api_key']}"
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Error: {str(e)}"
        }
