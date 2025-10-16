import json
import boto3
import os
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

table_name = os.environ['DYNAMODB_TABLE']
sns_topic_arn = os.environ['SNS_TOPIC_ARN']
temp_threshold = float(os.environ['TEMP_THRESHOLD'])

table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    """
    Process IoT temperature data
    - Store in DynamoDB
    - Send SNS alert if temperature exceeds threshold
    """
    try:
        print(f"Received event: {json.dumps(event)}")
        
        # Extract data from IoT message
        device_id = event.get('deviceId', 'unknown')
        temperature = float(event.get('temperature', 0))
        humidity = float(event.get('humidity', 0))
        timestamp = int(event.get('timestamp', datetime.now().timestamp()))
        
        # Store in DynamoDB
        item = {
            'deviceId': device_id,
            'timestamp': timestamp,
            'temperature': Decimal(str(temperature)),
            'humidity': Decimal(str(humidity)),
            'processedAt': datetime.now().isoformat()
        }
        
        table.put_item(Item=item)
        print(f"Stored data for device {device_id}")
        
        # Check if temperature exceeds threshold
        if temperature > temp_threshold:
            message = f"""
            🚨 Temperature Alert!
            
            Device: {device_id}
            Temperature: {temperature}°C
            Humidity: {humidity}%
            Threshold: {temp_threshold}°C
            Time: {datetime.fromtimestamp(timestamp).isoformat()}
            
            Action may be required.
            """
            
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject=f'High Temperature Alert - {device_id}',
                Message=message
            )
            print(f"Alert sent for device {device_id}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Data processed successfully',
                'deviceId': device_id,
                'temperature': temperature
            })
        }
        
    except Exception as e:
        print(f"Error processing data: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error processing data',
                'error': str(e)
            })
        }
