import json
import boto3
import os
from urllib.parse import unquote_plus

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    
    print(f"Received event: {json.dumps(event)}")
    
    processed_files = []
    errors = []
    
    for sqs_record in event['Records']:
        try:
            s3_event = json.loads(sqs_record['body'])
            
            for s3_record in s3_event['Records']:
                bucket_name = s3_record['s3']['bucket']['name']
                object_key = unquote_plus(s3_record['s3']['object']['key'])
                event_name = s3_record['eventName']
                
                print(f"Processing {event_name}: s3://{bucket_name}/{object_key}")
                
                response = s3_client.get_object(
                    Bucket=bucket_name,
                    Key=object_key
                )
                
                file_content = response['Body'].read().decode('utf-8')
                
                try:
                    data = json.loads(file_content)
                    print(f"File content: {json.dumps(data, indent=2)}")

                    processed_files.append({
                        'bucket': bucket_name,
                        'key': object_key,
                        'size': response['ContentLength'],
                        'status': 'success'
                    })
                    
                except json.JSONDecodeError as e:
                    print(f"File is not valid JSON: {str(e)}")
                    processed_files.append({
                        'bucket': bucket_name,
                        'key': object_key,
                        'size': response['ContentLength'],
                        'status': 'processed_as_text'
                    })
                
        except Exception as e:
            error_msg = f"Error processing record: {str(e)}"
            print(error_msg)
            errors.append(error_msg)
    
    return {
        'statusCode': 200 if not errors else 207,
        'body': json.dumps({
            'processed': len(processed_files),
            'files': processed_files,
            'errors': errors
        })
    }
