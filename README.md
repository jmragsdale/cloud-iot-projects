# Cloud IoT Data Processing Projects

Two professional IoT data processing systems demonstrating cloud architecture expertise on AWS and Azure platforms. These projects showcase serverless design, infrastructure-as-code, and real-time data processing capabilities.

## Projects Overview

### 1. AWS IoT Data Processing System
**Location**: `aws-iot-project/`

A serverless IoT pipeline using AWS IoT Core, Lambda, DynamoDB, and SNS.

**Key Technologies:**
- AWS IoT Core (MQTT broker, device management)
- AWS Lambda (serverless data processing)
- Amazon DynamoDB (NoSQL time-series storage)
- Amazon SNS (alerting)
- Terraform (infrastructure-as-code)

**Architecture Highlights:**
- X.509 certificate authentication
- IoT Rules Engine for message routing
- Real-time temperature alerting
- Serverless, auto-scaling design

[View AWS Project →](./aws-iot-project/README.md)

---

### 2. Azure IoT Data Processing System
**Location**: `azure-iot-project/`

A serverless IoT pipeline using Azure IoT Hub, Functions, Cosmos DB, and Event Hub.

**Key Technologies:**
- Azure IoT Hub (device registry, MQTT/AMQP)
- Azure Event Hub (event streaming)
- Azure Functions (serverless compute)
- Azure Cosmos DB (globally distributed NoSQL)
- Application Insights (monitoring)
- Terraform (infrastructure-as-code)

**Architecture Highlights:**
- Managed device identity
- Event-driven processing
- Global distribution capability
- Comprehensive monitoring

[View Azure Project →](./azure-iot-project/README.md)

---

## Comparison Matrix

| Feature | AWS Solution | Azure Solution |
|---------|-------------|----------------|
| **IoT Service** | AWS IoT Core | Azure IoT Hub |
| **Message Protocol** | MQTT over TLS | MQTT/AMQP |
| **Event Processing** | IoT Rules Engine | Event Hub + Functions |
| **Compute** | AWS Lambda | Azure Functions |
| **Storage** | DynamoDB | Cosmos DB |
| **Monitoring** | CloudWatch | Application Insights |
| **Alerting** | SNS | Function Logs |
| **IaC Tool** | Terraform | Terraform |
| **Free Tier** | 250K messages/month | 8K messages/day |

## Quick Start Guide

### Prerequisites
- AWS Account (for AWS project)
- Azure Account (for Azure project)
- Terraform >= 1.0
- AWS CLI (for AWS project) or Azure CLI (for Azure project)
- Python 3.8+

### Deploy AWS Project
```bash
cd aws-iot-project
chmod +x deploy.sh
./deploy.sh
```

### Deploy Azure Project
```bash
cd azure-iot-project
az login
chmod +x deploy.sh
./deploy.sh
```

## Architecture Patterns Demonstrated

### 1. **Serverless Architecture**
Both projects use fully serverless components that:
- Auto-scale based on demand
- Have no servers to manage
- Follow pay-per-use pricing models
- Provide built-in high availability

### 2. **Event-Driven Design**
Messages trigger processing functions automatically:
- Loose coupling between components
- Easy to add new consumers
- Natural backpressure handling
- Enables real-time processing

### 3. **Infrastructure as Code**
Complete infrastructure defined in Terraform:
- Version-controlled infrastructure
- Reproducible deployments
- Documentation through code
- Easy to tear down and rebuild

### 4. **IoT Best Practices**
- Secure device authentication
- Message validation and transformation
- Time-series data storage
- Real-time alerting
- Comprehensive monitoring

## Cost Analysis

### AWS Project (Monthly Estimate)
```
IoT Core:     Free tier (250K messages)
Lambda:       Free tier (1M requests)
DynamoDB:     Free tier (25GB + 25 WCU/RCU)
SNS:          Free tier (1K notifications)
Total:        ~$0-5 for light usage
```

### Azure Project (Monthly Estimate)
```
IoT Hub F1:   Free tier (8K messages/day)
Event Hub:    ~$10 (Basic tier)
Functions:    Free tier (1M executions)
Cosmos DB:    Pay-per-request (~$5-10)
Total:        ~$10-15 for light usage
```

## Skills Demonstrated

### Cloud Platforms
- ✅ AWS IoT Core, Lambda, DynamoDB, SNS, IAM
- ✅ Azure IoT Hub, Functions, Cosmos DB, Event Hub
- ✅ Multi-cloud architecture experience

### DevOps & IaC
- ✅ Terraform for infrastructure provisioning
- ✅ Automated deployment scripts
- ✅ Version control best practices

### Programming
- ✅ Python for serverless functions
- ✅ Async/await patterns
- ✅ SDK usage (AWS/Azure)

### IoT Concepts
- ✅ Device authentication and security
- ✅ Message protocols (MQTT, AMQP)
- ✅ Real-time data processing
- ✅ Time-series data management

### System Design
- ✅ Serverless architecture
- ✅ Event-driven design
- ✅ Scalability patterns
- ✅ Monitoring and observability

## Interview Preparation

### Common Questions & Answers

**Q: Why did you choose serverless architecture?**
A: Serverless eliminates infrastructure management overhead, provides automatic scaling, and offers pay-per-use pricing. It's ideal for IoT workloads with variable traffic patterns.

**Q: How does your solution handle scale?**
A: Both solutions automatically scale. AWS Lambda and Azure Functions can handle thousands of concurrent executions. DynamoDB and Cosmos DB provide consistent performance at any scale.

**Q: What about security?**
A: Devices authenticate using certificates or keys, data is encrypted in transit (TLS) and at rest, and functions use least-privilege IAM roles.

**Q: How do you monitor these systems?**
A: CloudWatch (AWS) and Application Insights (Azure) provide metrics, logs, and alerts. Both projects include logging at each processing stage.

**Q: What would you improve?**
A: Add API Gateway for HTTP access, implement device shadows/twins, add visualization dashboards, implement edge computing, add more sophisticated analytics.

**Q: Compare AWS vs Azure for IoT**
A: AWS has more mature IoT services and broader ecosystem. Azure has better enterprise integration and simpler pricing. Both are production-ready.

## Repository Structure

```
.
├── aws-iot-project/
│   ├── main.tf                 # AWS infrastructure
│   ├── lambda_function.py      # Data processing logic
│   ├── device_simulator.py     # IoT device simulator
│   ├── deploy.sh              # Deployment automation
│   └── README.md              # AWS-specific docs
│
├── azure-iot-project/
│   ├── main.tf                # Azure infrastructure
│   ├── function_app.py        # Data processing logic
│   ├── device_simulator.py    # IoT device simulator
│   ├── deploy.sh             # Deployment automation
│   └── README.md             # Azure-specific docs
│
└── README.md                  # This file
```

## Next Steps

1. **Deploy one or both projects** to see them in action
2. **Customize** the code with your own features
3. **Document your experience** for interviews
4. **Add to your resume** and GitHub profile
5. **Prepare talking points** about architecture decisions

## Cleanup

Both projects include cleanup scripts to remove all resources:

```bash
# AWS
cd aws-iot-project && ./cleanup.sh

# Azure
cd azure-iot-project && ./cleanup.sh
```

## Learning Resources

- [AWS IoT Developer Guide](https://docs.aws.amazon.com/iot/latest/developerguide/)
- [Azure IoT Hub Documentation](https://docs.microsoft.com/en-us/azure/iot-hub/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Contributing

These projects are designed for learning and portfolio purposes. Feel free to fork, modify, and extend them for your own use.

## License

MIT License - See individual project directories for details.

---

**Author**: Your Name  
**Purpose**: Cloud IoT portfolio projects  
**Last Updated**: October 2025  
**Status**: Production-ready for portfolio and learning
