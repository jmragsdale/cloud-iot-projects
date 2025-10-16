#!/bin/bash

set -e

echo "======================================"
echo "Azure IoT Data Processing System Setup"
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

if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check Azure login
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: Not logged in to Azure${NC}"
    echo "Please run: az login"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# Get user inputs
read -p "Enter Azure region [eastus]: " AZURE_REGION
AZURE_REGION=${AZURE_REGION:-eastus}

read -p "Enter project name (lowercase, no spaces) [azureiotdemo]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-azureiotdemo}

read -p "Enter your email for alerts (optional): " ALERT_EMAIL

# Validate project name
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9]+$ ]]; then
    echo -e "${RED}Error: Project name must contain only lowercase letters and numbers${NC}"
    exit 1
fi

# Create terraform.tfvars
echo "Creating terraform.tfvars..."
cat > terraform.tfvars <<EOF
azure_region    = "$AZURE_REGION"
project_name    = "$PROJECT_NAME"
alert_email     = "$ALERT_EMAIL"
environment     = "dev"
EOF

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
echo "This may take 5-10 minutes..."
terraform apply -auto-approve

# Get outputs
DEVICE_CONNECTION=$(terraform output -raw device_connection_string)
DEVICE_ID=$(terraform output -raw device_id)
FUNCTION_APP=$(terraform output -raw function_app_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)

echo ""
echo "Preparing Azure Function deployment..."

# Create a temporary directory for function deployment
FUNC_DIR="function_deploy"
mkdir -p $FUNC_DIR

# Copy function files
cp function_app.py $FUNC_DIR/
cp requirements.txt $FUNC_DIR/
cp host.json $FUNC_DIR/

# Deploy function
echo ""
echo "Deploying Azure Function..."
cd $FUNC_DIR
zip -r function.zip .
az functionapp deployment source config-zip \
    -g $RESOURCE_GROUP \
    -n $FUNCTION_APP \
    --src function.zip

cd ..
rm -rf $FUNC_DIR

echo ""
echo -e "${GREEN}======================================"
echo "Deployment Complete!"
echo "======================================${NC}"
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "Device ID: $DEVICE_ID"
echo "Function App: $FUNCTION_APP"
echo ""
echo "Next steps:"
echo "1. Install Python dependencies:"
echo "   pip install azure-iot-device"
echo ""
echo "2. Run the device simulator:"
echo "   python3 device_simulator.py \\"
echo "     --connection-string \"$DEVICE_CONNECTION\" \\"
echo "     --device-id $DEVICE_ID"
echo ""
echo "3. View data in Cosmos DB:"
echo "   az cosmosdb sql container query \\"
echo "     --resource-group $RESOURCE_GROUP \\"
echo "     --account-name $(terraform output -raw cosmos_db_endpoint | cut -d'.' -f1 | cut -d'/' -f3) \\"
echo "     --database-name $(terraform output -raw cosmos_db_database) \\"
echo "     --container-name $(terraform output -raw cosmos_db_container) \\"
echo "     --query \"SELECT * FROM c ORDER BY c.timestamp DESC OFFSET 0 LIMIT 10\""
echo ""
echo "4. View Function logs:"
echo "   az monitor log-analytics query \\"
echo "     --workspace $(az monitor log-analytics workspace list -g $RESOURCE_GROUP --query '[0].customerId' -o tsv) \\"
echo "     --analytics-query \"FunctionAppLogs | where FunctionName == 'process_iot_data' | order by TimeGenerated desc | take 20\""
echo ""
echo "5. Monitor in Azure Portal:"
echo "   https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP"
echo ""

# Save connection string to file
echo "$DEVICE_CONNECTION" > device_connection.txt
echo -e "${YELLOW}⚠ Device connection string saved to device_connection.txt${NC}"
echo ""

# Create cleanup script
cat > cleanup.sh <<'EOF'
#!/bin/bash
echo "Cleaning up Azure resources..."
terraform destroy -auto-approve
rm -rf .terraform .terraform.lock.hcl terraform.tfstate* device_connection.txt
echo "Cleanup complete!"
EOF
chmod +x cleanup.sh

echo "To destroy all resources later, run: ./cleanup.sh"
