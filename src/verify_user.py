import boto3
from os import getenv
from urllib.parse import parse_qsl
import json

def lambda_handler(event, context):
    s3_client = boto3.client("s3")
    try:
        query_string = event["queryStringParameters"]
        item_found = is_key_in_db(db_key=query_string)
        result_file = "index.html" if item_found else "error.html"
        print("result file:",result_file,"reading from bucket", getenv("WEBSITE_S3"))
        response = s3_client.get_object(Bucket=getenv("WEBSITE_S3"), Key=result_file)
        print("content readed", response)
        html_body = response["Body"].read().decode("utf-8")
        print("bucket:", html_body)
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "text/html"},
            "body": html_body,
        }
    except Exception as error_details:
        return {
            'statusCode': 502,
            'body': json.dumps("Error verifying user. Check Logs for more details")
        }


def is_key_in_db(db_key):
    db_client = boto3.resource("dynamodb")
    db_table = db_client.Table(getenv("DB_TABLE_NAME"))
    try:
        response = db_table.get_item(Key=db_key)
        if "Item" not in response:
            print(f"Item with key: {db_key} not found")
            return False
    except Exception as err:
        print(f"Error Getting Item: {err}")
        return False
    else:
        return True
