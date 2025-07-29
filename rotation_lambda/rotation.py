import boto3
import json

def lambda_handler(event, context):
    print("=== ROTATION HANDLER INVOKED ===")
    print("EVENT:", json.dumps(event))

    secret_arn = event['SecretId']
    client = boto3.client('secretsmanager')

    step = event['Step']
    token = event['ClientRequestToken']
    print(f"STEP: {step}")

    if step == "createSecret":
        try:
            client.get_secret_value(SecretId=secret_arn, VersionStage="AWSPENDING", VersionId=token)
            print("AWSPENDING version already exists, skipping createSecret.")
        except client.exceptions.ResourceNotFoundException:
            new_secret = '{"API_KEY": "new-rotated-api-key"}'
            client.put_secret_value(
                SecretId=secret_arn,
                ClientRequestToken=token,
                SecretString=new_secret,
                VersionStages=["AWSPENDING"]
            )
            print("New secret created.")

    elif step == "setSecret":
        print("setSecret: Nothing to do.")
    elif step == "testSecret":
        print("testSecret: Nothing to test.")
    elif step == "finishSecret":
        metadata = client.describe_secret(SecretId=secret_arn)
        current_version = None
        for version, stages in metadata['VersionIdsToStages'].items():
            if "AWSCURRENT" in stages:
                current_version = version
                break

        if current_version != token:
            client.update_secret_version_stage(
                SecretId=secret_arn,
                VersionStage="AWSCURRENT",
                MoveToVersionId=token,
                RemoveFromVersionId=current_version
            )
            print("Secret version promoted to AWSCURRENT.")
