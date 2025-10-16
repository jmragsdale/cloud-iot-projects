# Quick Reference Card - Cloud IoT Projects

## Project Summary

### AWS IoT Project
**Architecture**: IoT Core → Lambda → DynamoDB + SNS
**Deploy**: `cd aws-iot-project && ./deploy.sh`
**Test**: `python3 device_simulator.py --endpoint <endpoint> --cert certs/certificate.pem.crt --key certs/private.pem.key --root-ca certs/root-CA.crt`
**Monitor**: `aws dynamodb scan --table-name aws-iot-demo-iot-data`
**Cleanup**: `./cleanup.sh`

### Azure IoT Project
**Architecture**: IoT Hub → Event Hub → Functions → Cosmos DB
**Deploy**: `cd azure-iot-project && az login && ./deploy.sh`
**Test**: `python3 device_simulator.py --connection-string "$(cat device_connection.txt)"`
**Monitor**: Azure Portal > Cosmos DB > Data Explorer
**Cleanup**: `./cleanup.sh`

## Key Commands

### Prerequisites Installation
```bash
# Terraform
brew install terraform  # macOS
# or download from terraform.io

# AWS CLI
brew install awscli
aws configure

# Azure CLI
brew install azure-cli
az login
```

### GitHub Upload
```bash
cd cloud-iot-projects
git init
git add .
git commit -m "Initial commit: AWS and Azure IoT projects"
git remote add origin https://github.com/YOUR-USERNAME/cloud-iot-projects.git
git branch -M main
git push -u origin main
```

## Interview One-Liners

**Project Overview**: "Built two serverless IoT data processing systems using AWS and Azure, processing real-time sensor data with automatic scaling and monitoring"

**Tech Stack**: "AWS: IoT Core, Lambda, DynamoDB, SNS | Azure: IoT Hub, Functions, Cosmos DB, Event Hub | IaC: Terraform"

**Key Achievement**: "Implemented secure, scalable IoT pipelines processing thousands of messages with sub-second latency and zero server management"

## Cost Estimates

**AWS**: $0-5/month (within free tier)
**Azure**: $10-15/month (F1 IoT Hub free, basic Event Hub)

## File Structure
```
cloud-iot-projects/
├── README.md                    # Main overview
├── SETUP_GUIDE.md              # Detailed setup instructions
├── LICENSE                     # MIT License
├── aws-iot-project/
│   ├── README.md               # AWS documentation
│   ├── main.tf                 # Infrastructure code
│   ├── lambda_function.py      # Data processing
│   ├── device_simulator.py     # Test device
│   └── deploy.sh              # Deployment script
└── azure-iot-project/
    ├── README.md              # Azure documentation
    ├── main.tf                # Infrastructure code
    ├── function_app.py        # Data processing
    ├── device_simulator.py    # Test device
    └── deploy.sh             # Deployment script
```

## Troubleshooting Quick Fixes

**AWS device won't connect**: Check certs in `certs/` directory
**Azure device won't connect**: Verify connection string in `device_connection.txt`
**Terraform errors**: Run `terraform init` again
**High costs**: Run cleanup scripts immediately

## Resources

- Setup Guide: `SETUP_GUIDE.md`
- AWS Docs: https://docs.aws.amazon.com/iot/
- Azure Docs: https://docs.microsoft.com/en-us/azure/iot-hub/
- Terraform: https://registry.terraform.io/

## Next Actions

- [ ] Review SETUP_GUIDE.md
- [ ] Deploy AWS project
- [ ] Deploy Azure project  
- [ ] Upload to GitHub
- [ ] Add to resume
- [ ] Prepare interview answers
