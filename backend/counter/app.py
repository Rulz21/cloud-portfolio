import json
import os

import boto3
from botocore.config import Config

# Fail fast instead of hanging if DynamoDB is slow to respond
AWS_CONFIG = Config(connect_timeout=2, read_timeout=2, retries={"max_attempts": 2})

# Connect to the DynamoDB table. Its name comes from an environment variable set by Terraform.
table = boto3.resource("dynamodb", config=AWS_CONFIG).Table(os.environ["TABLE_NAME"])

def lambda_handler(event, context):
    """Runs every time the API is called: add 1 to the counter and return the new value."""
    response = table.update_item(
        Key={"id": "visitors"},
        UpdateExpression="ADD visit_count :one",
        ExpressionAttributeValues={":one": 1},
        ReturnValues="UPDATED_NEW",
    )
    count = int(response["Attributes"]["visit_count"])

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"count": count}),
    }