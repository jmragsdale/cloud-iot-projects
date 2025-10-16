# Complete Setup Guide for Cloud IoT Projects

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [AWS Project Setup](#aws-project-setup)
4. [Azure Project Setup](#azure-project-setup)
5. [Testing Your Projects](#testing-your-projects)
6. [GitHub Upload Instructions](#github-upload-instructions)
7. [Resume & Interview Tips](#resume--interview-tips)
8. [Troubleshooting](#troubleshooting)

---

## Overview

You have two professional IoT data processing systems ready for deployment:

1. **AWS IoT Project**: Uses IoT Core, Lambda, DynamoDB, SNS
2. **Azure IoT Project**: Uses IoT Hub, Functions, Cosmos DB, Event Hub

Both projects are fully functional, include complete documentation, and are ready to showcase on your resume and GitHub.

---

## Prerequisites

### For Both Projects
- Git installed
- Python 3.8 or higher
- pip (Python package manager)
- Terraform >= 1.0 installed

### For AWS Project
```bash
# Install AWS CLI
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Download and run: https://awscli.amazonaws.com/AWSCLIV2.msi

# Configure AWS credentials
aws configure
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Output format (json)
```

### For Azure Project
```bash
# Install Azure CLI
# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Windows
# Download and run: https://aka.ms/installazurecliwindows

# Login to Azure
az login
# This will open a browser for authentication
```

---

## AWS Project Setup

### Step 1: Navigate to Project
```bash
cd cloud-iot-projects/aws-iot-project
```

### Step 2: Review Configuration (Optional)
Edit `variables.tf` if you want to change defaults:
- AWS region (default: us-east-1)
- Project name (default: aws-iot-demo)
- Temperature threshold (default: 30°C)

### Step 3: Deploy Infrastructure
```bash
chmod +x deploy.sh
./deploy.sh
```

Follow the prompts:
- AWS region: Press Enter for us-east-1 or specify your preferred region
- Project name: Press Enter for default or specify custom name
- Alert email: Enter your email or leave blank

The script will:
- ✅ Validate prerequisites
- ✅ Package Lambda function
- ✅ Download root CA certificate
- ✅ Deploy all AWS resources
- ✅ Extract IoT certificates
- ✅ Save certificates to `certs/` directory

**Expected deployment time**: 2-3 minutes

### Step 4: Install Python Dependencies
```bash
pip install awsiotsdk
```

### Step 5: Run Device Simulator
The deployment script provides the exact command. It will look like:
```bash
python3 device_simulator.py \
  --endpoint your-endpoint.amazonaws.com \
  --cert certs/certificate.pem.crt \
  --key certs/private.pem.key \
  --root-ca certs/root-CA.crt \
  --client-id aws-iot-demo-temp-sensor
```

### Step 6: Monitor Data
**View DynamoDB Table:**
```bash
aws dynamodb scan --table-name aws-iot-demo-iot-data --max-items 5
```

**View Lambda Logs:**
```bash
aws logs tail /aws/lambda/aws-iot-demo-process-data --follow
```

**AWS Console:**
1. Navigate to AWS Console
2. Go to DynamoDB > Tables > aws-iot-demo-iot-data
3. Click "Explore table items"

### Step 7: Cleanup (When Done)
```bash
./cleanup.sh
```

---

## Azure Project Setup

### Step 1: Navigate to Project
```bash
cd cloud-iot-projects/azure-iot-project
```

### Step 2: Ensure Azure Login
```bash
az login
az account show  # Verify correct subscription
```

### Step 3: Deploy Infrastructure
```bash
chmod +x deploy.sh
./deploy.sh
```

Follow the prompts:
- Azure region: Press Enter for eastus or specify your preferred region
- Project name: Press Enter for default (lowercase, no spaces)
- Alert email: Enter your email or leave blank

The script will:
- ✅ Validate prerequisites
- ✅ Deploy all Azure resources (5-10 minutes)
- ✅ Deploy Azure Function
- ✅ Save device connection string

**Expected deployment time**: 8-12 minutes (Azure takes longer than AWS)

### Step 4: Install Python Dependencies
```bash
pip install azure-iot-device
```

### Step 5: Run Device Simulator
The connection string is saved in `device_connection.txt`. Run:
```bash
python3 device_simulator.py \
  --connection-string "$(cat device_connection.txt)" \
  --device-id temperature-sensor-001
```

### Step 6: Monitor Data
**Azure Portal:**
1. Go to portal.azure.com
2. Navigate to your resource group
3. Open Cosmos DB account
4. Go to Data Explorer
5. Expand iot-data > sensor-readings
6. Click "Items" to view data

**View Function Logs:**
```bash
az webapp log tail \
  --name <function-app-name> \
  --resource-group <resource-group-name>
```

### Step 7: Cleanup (When Done)
```bash
./cleanup.sh
```

---

## Testing Your Projects

### Generate Test Data
Both simulators support custom parameters:

**AWS:**
```bash
# Send 10 messages at 2-second intervals
python3 device_simulator.py \
  --endpoint ... \
  --cert ... \
  --key ... \
  --root-ca ... \
  --interval 2 \
  --count 10
```

**Azure:**
```bash
# Send 10 messages at 2-second intervals
python3 device_simulator.py \
  --connection-string "..." \
  --interval 2 \
  --count 10
```

### Trigger Alerts
Modify the simulator to send high temperatures:
- Edit `device_simulator.py`
- Change line: `temperature = base_temp + random.uniform(-5, 15)`
- To: `temperature = base_temp + random.uniform(10, 20)`
- Run simulator - this will trigger alerts

---

## GitHub Upload Instructions

### Step 1: Prepare Repository
```bash
cd cloud-iot-projects
```

### Step 2: Initialize Git
```bash
git init
git add .
git commit -m "Initial commit: AWS and Azure IoT projects"
```

### Step 3: Create GitHub Repository
1. Go to https://github.com/new
2. Repository name: `cloud-iot-projects`
3. Description: `Serverless IoT data processing systems on AWS and Azure`
4. Choose: **Public** (for portfolio visibility)
5. **Do NOT** check "Initialize with README"
6. Click "Create repository"

### Step 4: Push to GitHub
```bash
git remote add origin https://github.com/YOUR-USERNAME/cloud-iot-projects.git
git branch -M main
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username.

### Step 5: Enhance Your Repository
1. **Add Topics**: Click ⚙️ (Settings) on repo page
   - Add: `terraform`, `aws`, `azure`, `iot`, `serverless`, `python`, `cloud`
2. **Pin Repository**: Go to your profile and pin this repo
3. **Add Website**: Add link to live demo (if hosted)
4. **Star Technologies**: Star AWS/Azure SDKs, Terraform, etc.

---

## Resume & Interview Tips

### Resume Bullet Points

**Example 1:**
"Developed serverless IoT data processing systems on AWS and Azure using Infrastructure-as-Code (Terraform), processing real-time sensor data with automatic scaling and monitoring"

**Example 2:**
"Built cloud-native IoT solutions utilizing AWS Lambda, DynamoDB, Azure Functions, and Cosmos DB, demonstrating expertise in event-driven architecture and multi-cloud development"

**Example 3:**
"Implemented secure IoT device communication using MQTT/AMQP protocols with certificate-based authentication, processing and storing time-series data in serverless NoSQL databases"

### Interview Talking Points

**Q: Tell me about your IoT projects**
"I built two IoT data processing systems - one on AWS and one on Azure - to demonstrate my cloud architecture skills. Both systems handle real-time temperature and humidity data from IoT devices, process it through serverless functions, store it in NoSQL databases, and trigger alerts when thresholds are exceeded. I used Terraform for infrastructure-as-code to make the deployments reproducible."

**Q: Why did you choose serverless?**
"Serverless architecture eliminates infrastructure management, provides automatic scaling, and offers pay-per-use pricing. For IoT workloads with variable traffic patterns, this means I only pay for actual device messages rather than maintaining always-on servers. The systems can scale from zero to thousands of devices without code changes."

**Q: How do you handle security?**
"Both projects implement security best practices: devices authenticate using certificates or access keys, all communication is encrypted with TLS, functions use least-privilege IAM roles, and data is encrypted at rest in the databases. I also follow the principle of defense in depth with multiple security layers."

**Q: What challenges did you face?**
"One challenge was managing the different approaches between AWS and Azure - AWS uses IoT Rules Engine for routing while Azure uses Event Hub. I had to understand each platform's native patterns. Another challenge was cost optimization, which I solved by using free tiers and serverless billing models."

**Q: How would you scale this?**
"Both solutions are built to scale horizontally. AWS Lambda and Azure Functions auto-scale based on load. DynamoDB and Cosmos DB provide consistent performance at any scale. To handle millions of devices, I'd implement device grouping, add caching with ElastiCache/Redis, and use Time Series databases like Timestream or Time Series Insights for better analytics."

---

## Troubleshooting

### AWS Issues

**Problem**: Device can't connect
```bash
# Verify endpoint
terraform output iot_endpoint

# Check certificates exist
ls -la certs/

# Test MQTT connection
mosquitto_pub --cafile certs/root-CA.crt \
  --cert certs/certificate.pem.crt \
  --key certs/private.pem.key \
  -h your-endpoint.amazonaws.com \
  -p 8883 \
  -t iot/temperature \
  -m '{"test":true}'
```

**Problem**: Lambda not triggering
```bash
# Check IoT rule
aws iot get-topic-rule --rule-name aws_iot_demo_rule

# Check Lambda permissions
aws lambda get-policy --function-name aws-iot-demo-process-data
```

**Problem**: No data in DynamoDB
```bash
# Check Lambda logs for errors
aws logs tail /aws/lambda/aws-iot-demo-process-data

# Verify IAM permissions
aws iam get-role-policy --role-name aws-iot-demo-lambda-role --policy-name aws-iot-demo-lambda-policy
```

### Azure Issues

**Problem**: Device can't connect
```bash
# Verify IoT Hub exists
az iot hub show --name <hub-name>

# Test connection
az iot device send-d2c-message \
  --hub-name <hub-name> \
  --device-id temperature-sensor-001 \
  --data '{"test":true}'
```

**Problem**: Function not triggering
```bash
# Check Function status
az functionapp show --name <function-name> --resource-group <rg-name>

# View Function logs
az functionapp log tail --name <function-name> --resource-group <rg-name>

# Check Event Hub metrics
az monitor metrics list \
  --resource <event-hub-resource-id> \
  --metric IncomingMessages
```

**Problem**: No data in Cosmos DB
```bash
# Query Cosmos DB
az cosmosdb sql container query \
  --resource-group <rg-name> \
  --account-name <cosmos-name> \
  --database-name iot-data \
  --container-name sensor-readings \
  --query "SELECT * FROM c"
```

### General Issues

**Terraform state locked**
```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

**Python dependency issues**
```bash
# Use virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
pip install -r requirements.txt
```

---

## Cost Management

### Monitor Costs

**AWS:**
```bash
# View current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics UnblendedCost
```

**Azure:**
```bash
# View current costs
az consumption usage list \
  --start-date $(date -d "$(date +%Y-%m-01)" +%Y-%m-%d) \
  --end-date $(date +%Y-%m-%d)
```

### Stay in Free Tier

**AWS Free Tier Limits:**
- IoT Core: 250,000 messages/month
- Lambda: 1M requests/month
- DynamoDB: 25GB storage + 25 WCU/RCU
- SNS: 1,000 notifications/month

**Azure Free Tier Limits:**
- IoT Hub F1: 8,000 messages/day
- Functions: 1M executions/month
- Cosmos DB: Pay-per-request (start small)

**To stay free:**
- Run simulator for short periods
- Use `--count` parameter to limit messages
- Delete resources when not actively demoing

---

## Next Steps

1. ✅ Deploy both projects
2. ✅ Test thoroughly
3. ✅ Upload to GitHub
4. ✅ Add to resume
5. ✅ Prepare interview talking points
6. 📝 Consider adding features:
   - Visualization dashboards
   - Additional device types
   - Machine learning integration
   - Historical data analysis

---

## Support Resources

- **AWS Documentation**: https://docs.aws.amazon.com/iot/
- **Azure Documentation**: https://docs.microsoft.com/en-us/azure/iot-hub/
- **Terraform Registry**: https://registry.terraform.io/
- **Project Issues**: Open issue on GitHub if you find problems

---

**Good luck with your projects and interviews! 🚀**
