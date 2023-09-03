#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import json
import boto3
import csv
from io import StringIO

def lambda_handler(event, context):
    # Define the source and destination S3 buckets
    source_bucket = "s3rawawsinbound"
    destination_bucket = "s3refinedbucket"
    
    # Get the S3 object key from the event
    s3_object_key = event['Records'][0]['s3']['object']['key']
    
    # Initialize S3 client
    s3_client = boto3.client('s3')
    
    try:
        # Retrieve the JSON object from the source bucket
        response = s3_client.get_object(Bucket=source_bucket, Key=s3_object_key)
        json_data = response['Body'].read().decode('utf-8')
        
        # Parse the JSON data
        data = json.loads(json_data)
        
        # Define a list to store CSV rows
        csv_rows = []
        
        # Extract column headers from the JSON keys
        headers = list(data[0].keys())
        
        # Append headers as the first row in the CSV
        csv_rows.append(headers)
        
        # Iterate through JSON data and convert it to CSV rows
        for item in data:
            row = [str(item[key]) for key in headers]
            csv_rows.append(row)
        
        # Create a CSV string from the rows
        csv_buffer = StringIO()
        csv_writer = csv.writer(csv_buffer)
        csv_writer.writerows(csv_rows)
        
        # Define the destination S3 object key with the same name but different extension
        destination_object_key = s3_object_key.replace('.json', '.csv')
        
        # Upload the converted CSV to the destination bucket
        s3_client.put_object(Bucket=destination_bucket, Key=destination_object_key, Body=csv_buffer.getvalue())
        
        # Return a success response
        return {
            'statusCode': 200,
            'body': 'JSON to CSV conversion and upload successful'
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error_message': str(e)})
        }

