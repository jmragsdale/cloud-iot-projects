# Azure IoT Data Processing System

A serverless IoT data processing pipeline built on Azure that demonstrates real-time data ingestion, processing, storage, and monitoring capabilities.

## Architecture

```
┌─────────────────┐
│  IoT Device     │
│  (Simulator)    │
│  Temperature    │
│  & Humidity     │
└────────┬────────┘
         │ AMQP/MQTT
         │
         ▼
┌──────────────────────────────────────────────────┐
│            Azure IoT Hub                         │
│  • Device Registry & Authentication              │
│  • Message Broker (MQTT/AMQP)                   │
│  • Device-to-Cloud Communication                 │
└────────┬─────────────────────────────────────────┘
         │
         │ Route Messages
         │
         ▼
┌──────────────────────────────────────────────────┐
│            Azure Event Hub                       │
│  • Message Streaming                             │
│  • Event Processing                              │
└────────┬─────────────────────────────────────────┘
         │
         │ Trigger
         │
         ▼
┌──────────────────────────────────────────────────┐
│         Azure Functions                          │
│  • Process IoT Messages                          │
│  • Validate & Transform Data                     │
│  • Temperature Threshold Check                   │
│  • Generate Alerts                               │
└────────┬──────────────┬──────────────────────────┘
         │              │
         │ Store        │ Log Alerts
         │              │
         ▼              ▼
┌─────────────────┐   ┌──────────────────┐
│  Cosmos DB      │   │ App Insights     │
│  • NoSQL Store  │   │ • Monitoring     │
│  • Time Series  │   │ • Logging        │
│  • Serverless   │   │ • Analytics      │
└─────────────────┘   └──────────────────┘
```

## Features

- **Managed IoT**: Azure IoT Hub handles device management and secure communication
- **Real-time Processing**: Event Hub and Functions process data as it arrives
- **Scalable Storage**: Cosmos DB provides globally distributed, serverless storage
- **Built-in Monitoring**: Application Insights for comprehensive observability
- **Serverless Architecture**: Pay only for what you use, auto-scales automatically
- **Temperature Alerts**: Automatic logging when temperature exceeds threshold

## Components

### Infrastructure (Terraform)
- **Azure IoT Hub**: Device registry and MQTT/AMQP broker (Free tier F1)
- **Event Hub**: Event streaming for IoT messages
- **Azure Functions**: Serverless compute for data processing (Consumption plan)
- **Cosmos DB**: Globally distributed NoSQL database (Serverless)
- **Application Insights**: Application monitoring and analytics
- **Storage Account**: Required for Azure Functions

### Application Code
- **Azure Function**: Python function triggered by Event Hub
- **Device Simulator**: Python script that sends telemetry to IoT Hub

## Prerequisites

- Azure Account with active subscription
- Terraform >= 1.0
- Azure CLI installed and configured
- Python 3.8+
- pip (Python package manager)

## Quick Start

### 1. Clone and Navigate
```bash
git clone <your-repo>
cd azure-iot-project
```

### 2. Login to Azure
```bash
az login
```

### 3. Deploy Infrastructure
```bash
chmod +x deploy.sh
./deploy.sh
```

The script will:
- Validate prerequisites
- Prompt for configuration (region, project name, alert email)
- Deploy all Azure resources using Terraform
- Deploy the Azure Function
- Save device connection string
- Provide next steps

### 4. Install Python Dependencies
```bash
pip install azure-iot-device
```

### 5. Run Device Simulator
```bash
python3 device_simulator.py \
  --connection-string "<your-connection-string>" \
  --device-id temperature-sensor-001
```

The connection string is saved in `device_connection.txt` after deployment.

### 6. Monitor Data

**View in Azure Portal:**
1. Navigate to your Resource Group
2. Open Cosmos DB account
3. Go to Data Explorer
4. Query the `sensor-readings` container

**View using Azure CLI:**
```bash
# Query recent data
az cosmosdb sql container query \
  --resource-group <resource-group> \
  --account-name <cosmos-account> \
  --database-name iot-data \
  --container-name sensor-readings \
  --query "SELECT * FROM c ORDER BY c.timestamp DESC OFFSET 0 LIMIT 10"
```

**View Function Logs:**
```bash
# Stream logs
az webapp log tail --name <function-app-name> --resource-group <resource-group>
```

**Application Insights:**
- Navigate to Azure Portal > Application Insights
- View live metrics, logs, and performance data

## Configuration

Edit `terraform.tfvars` or modify variables:

```hcl
azure_region          = "eastus"
project_name          = "azureiotdemo"
temperature_threshold = "30"  # Celsius
alert_email           = "your-email@example.com"
```

## Data Flow

1. **Device → IoT Hub**: Simulator sends JSON messages via AMQP
   ```json
   {
     "deviceId": "temperature-sensor-001",
     "temperature": 28.5,
     "humidity": 65.2,
     "timestamp": 1698765432
   }
   ```

2. **IoT Hub → Event Hub**: Messages routed to Event Hub

3. **Event Hub → Function**: Function triggered by new messages

4. **Function Processing**:
   - Parses and validates data
   - Stores document in Cosmos DB
   - Checks temperature threshold
   - Logs alert if threshold exceeded

5. **Cosmos DB Storage**: Document stored with automatic partitioning by deviceId

6. **Application Insights**: All telemetry and logs sent for monitoring

## Project Structure

```
azure-iot-project/
├── main.tf               # Main Terraform configuration
├── variables.tf          # Input variables
├── outputs.tf            # Output values
├── function_app.py       # Azure Function code
├── requirements.txt      # Python dependencies
├── host.json            # Function host configuration
├── device_simulator.py   # IoT device simulator
├── deploy.sh            # Automated deployment script
├── cleanup.sh           # Resource cleanup script (generated)
└── README.md            # This file
```

## Cost Estimation

This project uses Azure Free tier and serverless services:

- **IoT Hub F1**: Free tier (8,000 messages/day)
- **Event Hub Basic**: ~$10/month
- **Functions Consumption**: First 1M executions free, then $0.20/million
- **Cosmos DB Serverless**: Pay per request (~$0.25/million reads)
- **Application Insights**: 5 GB/month free

**Estimated cost** (light usage): ~$10-15/month

## Interview Talking Points

**Architecture Decisions:**
- *Why Azure Functions?* Event-driven, serverless, integrates natively with Event Hub
- *Why Cosmos DB?* Multi-region, serverless, excellent for IoT time-series data
- *Why Event Hub?* Decouples ingestion from processing, enables multiple consumers

**Scalability:**
- IoT Hub handles millions of devices
- Event Hub processes millions of events/second
- Functions auto-scale from 0 to 200+ instances
- Cosmos DB provides unlimited throughput and storage

**Security:**
- Device authentication via shared access keys or X.509 certificates
- Managed identities for Azure Functions
- Private endpoints supported (not implemented for cost)
- Data encrypted in transit and at rest

**Monitoring & Operations:**
- Application Insights provides end-to-end visibility
- Built-in metrics for all Azure services
- Log Analytics for querying logs
- Alerts and dashboards in Azure Monitor

**Reliability:**
- Built-in high availability for all services
- Automatic failover for Cosmos DB
- Retry policies in Functions
- Dead letter queues available

## Cleanup

To remove all resources and avoid charges:

```bash
./cleanup.sh
```

Or manually:
```bash
terraform destroy -auto-approve
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* device_connection.txt
```

## Enhancements Ideas

- Add Azure Stream Analytics for real-time analytics
- Implement Azure Digital Twins for device modeling
- Add Power BI dashboard for visualization
- Implement device twins for device configuration
- Add Azure Logic Apps for advanced alerting workflows
- Implement IoT Edge for edge computing scenarios
- Add Azure Time Series Insights for time-series analytics

## Troubleshooting

**Device can't connect:**
- Verify connection string is correct
- Check IoT Hub is accessible
- Ensure device is registered in IoT Hub

**Function not triggering:**
- Check Event Hub connection string in Function app settings
- Verify messages are reaching Event Hub (check metrics)
- Check Function logs for errors

**No data in Cosmos DB:**
- Check Function logs for errors
- Verify Cosmos DB connection string
- Check Function has permissions to write to Cosmos DB

**High costs:**
- Check you're using F1 tier for IoT Hub
- Verify Cosmos DB is in serverless mode
- Monitor Function execution count

## Testing the System

### Send Test Data Manually
```bash
# Using Azure CLI
az iot device send-d2c-message \
  --hub-name <iot-hub-name> \
  --device-id temperature-sensor-001 \
  --data '{"deviceId":"temperature-sensor-001","temperature":35.5,"humidity":60,"timestamp":1698765432}'
```

### Query Data
```bash
# Query Cosmos DB
az cosmosdb sql container query \
  --resource-group <resource-group> \
  --account-name <cosmos-account> \
  --database-name iot-data \
  --container-name sensor-readings \
  --query "SELECT c.deviceId, c.temperature, c.humidity, c.timestamp FROM c WHERE c.temperature > 30"
```

## Resources

- [Azure IoT Hub Documentation](https://docs.microsoft.com/en-us/azure/iot-hub/)
- [Azure Functions Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Cosmos DB Documentation](https://docs.microsoft.com/en-us/azure/cosmos-db/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure IoT Python SDK](https://github.com/Azure/azure-iot-sdk-python)

## License

MIT License - See LICENSE file for details

---

**Author**: Your Name  
**Purpose**: Portfolio project demonstrating Azure IoT and serverless architecture  
**Last Updated**: 2025
