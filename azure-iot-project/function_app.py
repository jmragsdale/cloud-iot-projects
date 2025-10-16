import logging
import json
import os
from datetime import datetime
import azure.functions as func
from azure.cosmos import CosmosClient
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Configuration
cosmos_connection = os.environ['COSMOS_DB_CONNECTION_STRING']
cosmos_database = os.environ['COSMOS_DB_DATABASE']
cosmos_container = os.environ['COSMOS_DB_CONTAINER']
temp_threshold = float(os.environ.get('TEMP_THRESHOLD', 30))
alert_email = os.environ.get('ALERT_EMAIL', '')

# Initialize Cosmos DB client
cosmos_client = CosmosClient.from_connection_string(cosmos_connection)
database = cosmos_client.get_database_client(cosmos_database)
container = database.get_container_client(cosmos_container)

app = func.FunctionApp()

@app.event_hub_message_trigger(
    arg_name="azeventhub",
    event_hub_name="iot-messages",
    connection="IOTHUB_CONNECTION_STRING"
)
def process_iot_data(azeventhub: func.EventHubEvent):
    """
    Process IoT temperature data from Event Hub
    - Store in Cosmos DB
    - Check temperature threshold
    - Log alert if threshold exceeded
    """
    try:
        # Get message body
        message_body = azeventhub.get_body().decode('utf-8')
        logging.info(f'Received message: {message_body}')
        
        # Parse JSON data
        data = json.loads(message_body)
        
        # Extract fields
        device_id = data.get('deviceId', 'unknown')
        temperature = float(data.get('temperature', 0))
        humidity = float(data.get('humidity', 0))
        timestamp = data.get('timestamp', int(datetime.now().timestamp()))
        
        # Create document for Cosmos DB
        document = {
            'id': f"{device_id}-{timestamp}",
            'deviceId': device_id,
            'temperature': temperature,
            'humidity': humidity,
            'timestamp': timestamp,
            'processedAt': datetime.now().isoformat(),
            'partitionKey': device_id
        }
        
        # Store in Cosmos DB
        container.create_item(body=document)
        logging.info(f'Stored data for device {device_id}')
        
        # Check temperature threshold
        if temperature > temp_threshold:
            alert_message = f"""
            🚨 Temperature Alert!
            
            Device: {device_id}
            Temperature: {temperature}°C
            Humidity: {humidity}%
            Threshold: {temp_threshold}°C
            Time: {datetime.fromtimestamp(timestamp).isoformat()}
            
            Action may be required.
            """
            
            logging.warning(f'ALERT: High temperature detected on {device_id}: {temperature}°C')
            logging.warning(alert_message)
            
            # In production, you would send email via SendGrid, Azure Communication Services, etc.
            if alert_email:
                logging.info(f'Alert would be sent to: {alert_email}')
        
        logging.info(f'Successfully processed message from {device_id}')
        
    except Exception as e:
        logging.error(f'Error processing message: {str(e)}')
        raise


@app.route(route="health", methods=["GET"])
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    """Health check endpoint"""
    return func.HttpResponse(
        json.dumps({"status": "healthy", "timestamp": datetime.now().isoformat()}),
        mimetype="application/json",
        status_code=200
    )


@app.route(route="stats", methods=["GET"])
def get_stats(req: func.HttpRequest) -> func.HttpResponse:
    """Get statistics from Cosmos DB"""
    try:
        # Query recent data
        query = "SELECT * FROM c ORDER BY c.timestamp DESC OFFSET 0 LIMIT 10"
        items = list(container.query_items(query=query, enable_cross_partition_query=True))
        
        return func.HttpResponse(
            json.dumps(items, indent=2),
            mimetype="application/json",
            status_code=200
        )
    except Exception as e:
        return func.HttpResponse(
            json.dumps({"error": str(e)}),
            mimetype="application/json",
            status_code=500
        )
