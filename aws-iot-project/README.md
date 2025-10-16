# AWS IoT Data Processing System

A serverless IoT data processing pipeline built on AWS that demonstrates real-time data ingestion, processing, storage, and alerting capabilities.

## Architecture

```
┌─────────────────┐
│  IoT Device     │
│  (Simulator)    │
│  Temperature    │
│  & Humidity     │
└────────┬────────┘
         │ MQTT/TLS
         │
         ▼
┌─────────────────────────────────────────────────────┐
│              AWS IoT Core                           │
│  • Device Authentication (X.509 Certificates)       │
│  • Message Broker (MQTT)                            │
│  • IoT Rules Engine                                 │
└────────┬─────────────────────┬──────────────────────┘
         │                     │
         │ Trigger             │ Route
         │                     │
         ▼                     ▼
┌─────────────────┐   ┌─────────────────┐
│  AWS Lambda     │   │   Amazon SNS    │
│  Process Data   │   │  Alert Topic    │
│  • Validate     │   │                 │
│  • Transform    │   └────────┬────────┘
│  • Alert Check  │            │
└────────┬────────┘            │ Email
         │                     │
         │ Store               ▼
         │              ┌─────────────┐
         ▼              │    User     │
┌─────────────────┐     │  (Alerts)   │
│   DynamoDB      │     └─────────────┘
│  • Time Series  │
│  • Query Data   │
└─────────────────┘
```

## Features

- **Real-time Data Ingestion**: IoT devices publish temperature and humidity data via MQTT
- **Secure Communication**: X.509 certificate-based device authentication
- **Serverless Processing**: AWS Lambda processes incoming data automatically
- **Persistent Storage**: DynamoDB stores time-series sensor data
- **Smart Alerting**: SNS notifications when temperature exceeds threshold
- **Scalable**: Handles thousands of devices with pay-per-use pricing

## Components

### Infrastructure (Terraform)
- **AWS IoT Core**: Device registry, MQTT broker, and rules engine
- **AWS Lambda**: Serverless function for data processing
- **DynamoDB**: NoSQL database for time-series data storage
- **SNS**: Email notifications for temperature alerts
- **IAM**: Secure role-based access control

### Application Code
- **Lambda Function**: Python function that processes IoT messages
- **Device Simulator**: Python script that simulates IoT sensor data

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured with credentials
- Python 3.8+
- pip (Python package manager)

## Quick Start

### 1. Clone and Navigate
```bash
git clone <your-repo>
cd aws-iot-project
```

### 2. Deploy Infrastructure
```bash
chmod +x deploy.sh
./deploy.sh
```

The script will:
- Validate prerequisites
- Prompt for configuration (region, project name, alert email)
- Package the Lambda function
- Deploy all AWS resources using Terraform
- Extract and save IoT certificates
- Provide next steps

### 3. Install Python Dependencies
```bash
pip install awsiotsdk
```

### 4. Run Device Simulator
```bash
python3 device_simulator.py \
  --endpoint <your-iot-endpoint> \
  --cert certs/certificate.pem.crt \
  --key certs/private.pem.key \
  --root-ca certs/root-CA.crt \
  --client-id aws-iot-demo-temp-sensor
```

### 5. Monitor Data

**View DynamoDB Data:**
```bash
aws dynamodb scan --table-name <table-name> --max-items 10
```

**View Lambda Logs:**
```bash
aws logs tail /aws/lambda/<function-name> --follow
```

**Check CloudWatch Metrics:**
- Navigate to AWS Console > CloudWatch
- View IoT Core, Lambda, and DynamoDB metrics

## Configuration

Edit `terraform.tfvars` or modify variables:

```hcl
aws_region           = "us-east-1"
project_name         = "aws-iot-demo"
temperature_threshold = "30"  # Celsius
alert_email          = "your-email@example.com"
```

## Data Flow

1. **Device → IoT Core**: Simulator publishes JSON messages to `iot/temperature` topic
   ```json
   {
     "deviceId": "temp-sensor-001",
     "temperature": 28.5,
     "humidity": 65.2,
     "timestamp": 1698765432
   }
   ```

2. **IoT Rule → Lambda**: Rule triggers Lambda when messages arrive

3. **Lambda Processing**:
   - Validates data
   - Stores in DynamoDB
   - Checks temperature threshold
   - Sends SNS alert if threshold exceeded

4. **DynamoDB Storage**: Data stored with deviceId and timestamp as keys

5. **SNS Alert**: Email sent if temperature > threshold

## Project Structure

```
aws-iot-project/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── lambda_function.py   # Lambda processing code
├── device_simulator.py  # IoT device simulator
├── deploy.sh           # Automated deployment script
├── cleanup.sh          # Resource cleanup script (generated)
└── README.md           # This file
```

## Cost Estimation

This project uses AWS Free Tier eligible services:

- **IoT Core**: 250,000 messages/month free
- **Lambda**: 1M requests + 400,000 GB-seconds/month free
- **DynamoDB**: 25 GB storage + 25 WCU/RCU free
- **SNS**: 1,000 notifications/month free

**Estimated cost** (beyond free tier): ~$5-10/month for moderate usage

## Interview Talking Points

**Architecture Decisions:**
- *Why serverless?* Eliminates server management, auto-scales, pay-per-use
- *Why DynamoDB?* Purpose-built for time-series data, serverless, highly available
- *Why IoT Rules Engine?* No code required for routing, integrated with AWS services

**Scalability:**
- Handles millions of devices with no infrastructure changes
- Lambda auto-scales from 0 to 1000+ concurrent executions
- DynamoDB provides consistent single-digit millisecond latency

**Security:**
- X.509 certificates for device authentication
- IAM roles with least-privilege access
- Encrypted data in transit (TLS) and at rest

**Monitoring & Operations:**
- CloudWatch metrics for all services
- Lambda logs for debugging
- SNS for operational alerts
- X-Ray for distributed tracing (optional)

## Cleanup

To remove all resources and avoid charges:

```bash
./cleanup.sh
```

Or manually:
```bash
terraform destroy -auto-approve
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* certs/ lambda_function.zip
```

## Enhancements Ideas

- Add API Gateway for HTTP API access to data
- Implement Kinesis Data Streams for real-time analytics
- Add QuickSight dashboard for visualization
- Implement device shadow for device state management
- Add Timestream for optimized time-series queries
- Implement AWS IoT Analytics for advanced analytics

## Troubleshooting

**Device can't connect:**
- Verify certificates are in `certs/` directory
- Check IoT endpoint URL is correct
- Ensure IoT policy allows connect/publish

**Lambda not triggering:**
- Check IoT rule is enabled
- Verify topic matches rule SQL statement
- Check Lambda execution role permissions

**No data in DynamoDB:**
- Check Lambda logs for errors
- Verify Lambda has DynamoDB write permissions
- Check Lambda timeout (should be 30s)

## Resources

- [AWS IoT Core Documentation](https://docs.aws.amazon.com/iot/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS IoT SDK for Python](https://github.com/aws/aws-iot-device-sdk-python-v2)

## License

MIT License - See LICENSE file for details

---

**Author**: Your Name  
**Purpose**: Portfolio project demonstrating AWS IoT and serverless architecture  
**Last Updated**: 2025
