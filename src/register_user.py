import boto3
from os import getenv
from urllib.parse import parse_qsl
import json

def lambda_handler(event, context):
    query_string = event["queryStringParameters"]
    client = boto3.resource("dynamodb")
    db_table = client.Table(getenv("DB_TABLE_NAME"))
    try:
        response = db_table.put_item(Item=query_string)
        return {
            'statusCode': 200,
            'body': json.dumps("Registered User Successfully")
        }   
    except Exception as error_details:
        return {
            'statusCode': 502,
            'body': json.dumps("Error registering user. Check Logs for more details.")
        }
