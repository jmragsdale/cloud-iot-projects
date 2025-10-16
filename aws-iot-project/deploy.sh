#!/bin/bash

set -e

echo "======================================"
echo "AWS IoT Data Processing System Setup"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed${NC}"
    echo "Please install Terraform: https://www.terraform.io/downloads"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials not configured${NC}"
    echo "Please run: aws configure"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# Get user inputs
read -p "Enter AWS region [us-east-1]: " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

read -p "Enter project name [aws-iot-demo]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-aws-iot-demo}

read -p "Enter your email for alerts (optional): " ALERT_EMAIL

# Create terraform.tfvars
echo "Creating terraform.tfvars..."
cat > terraform.tfvars <<EOF
aws_region    = "$AWS_REGION"
project_name  = "$PROJECT_NAME"
alert_email   = "$ALERT_EMAIL"
environment   = "dev"
EOF

# Package Lambda function
echo ""
echo "Packaging Lambda function..."
if [ -f lambda_function.zip ]; then
    rm lambda_function.zip
fi
zip lambda_function.zip lambda_function.py
echo -e "${GREEN}✓ Lambda function packaged${NC}"

# Download root CA certificate
echo ""
echo "Downloading AWS IoT Root CA certificate..."
if [ ! -f root-CA.crt ]; then
    curl -o root-CA.crt https://www.amazontrust.com/repository/AmazonRootCA1.pem
    echo -e "${GREEN}✓ Root CA downloaded${NC}"
else
    echo -e "${YELLOW}Root CA already exists${NC}"
fi

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

# Plan
echo ""
echo "Planning Terraform deployment..."
terraform plan

# Apply
echo ""
read -p "Do you want to apply these changes? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

echo ""
echo "Deploying infrastructure..."
terraform apply -auto-approve

# Extract certificates
echo ""
echo "Extracting IoT certificates..."
mkdir -p certs

terraform output -raw certificate_pem > certs/certificate.pem.crt
terraform output -raw private_key > certs/private.pem.key
cp root-CA.crt certs/

echo -e "${GREEN}✓ Certificates saved to certs/ directory${NC}"

# Get outputs
IOT_ENDPOINT=$(terraform output -raw iot_endpoint)
THING_NAME=$(terraform output -raw thing_name)

echo ""
echo -e "${GREEN}======================================"
echo "Deployment Complete!"
echo "======================================${NC}"
echo ""
echo "IoT Endpoint: $IOT_ENDPOINT"
echo "Thing Name: $THING_NAME"
echo "Certificates: ./certs/"
echo ""
echo "Next steps:"
echo "1. Install Python dependencies:"
echo "   pip install awsiotsdk"
echo ""
echo "2. Run the device simulator:"
echo "   python3 device_simulator.py \\"
echo "     --endpoint $IOT_ENDPOINT \\"
echo "     --cert certs/certificate.pem.crt \\"
echo "     --key certs/private.pem.key \\"
echo "     --root-ca certs/root-CA.crt \\"
echo "     --client-id $THING_NAME"
echo ""
echo "3. View data in DynamoDB:"
echo "   aws dynamodb scan --table-name $(terraform output -raw dynamodb_table)"
echo ""
echo "4. View Lambda logs:"
echo "   aws logs tail /aws/lambda/$(terraform output -raw lambda_function) --follow"
echo ""
if [ -n "$ALERT_EMAIL" ]; then
    echo -e "${YELLOW}⚠ Important: Check your email and confirm the SNS subscription!${NC}"
    echo ""
fi

# Create cleanup script
cat > cleanup.sh <<'EOF'
#!/bin/bash
echo "Cleaning up AWS IoT resources..."
terraform destroy -auto-approve
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* certs/ lambda_function.zip
echo "Cleanup complete!"
EOF
chmod +x cleanup.sh

echo "To destroy all resources later, run: ./cleanup.sh"
