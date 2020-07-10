# Setting up Azure DevOps pipelines

## Requirements

- Azure CLI
- Terraform
- Git
- [Azure Devops extension for Azure CLI](https://github.com/Azure/azure-devops-cli-extension)
- [PAT for Azure DevOps CLI](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page#create-personal-access-tokens-to-authenticate-access)
  * `Agent Pools`: Read
  * `Build`: Read & Execute
  * `Code`: Read, write, & manage
  * `Project and Team`: Read, write & manage
  * `Release`: Read, write, execute, & manage

  _Note: PAT has permissions to manage ADO Projects in this example!_

```bash
az extension add --name azure-devops
```

__NOTE: Azure CLI, Terraform and Git are pre-installed in Rover (Dev Container)__

## Create the Service Principal for CI/CD

```bash
cd /tf/caf-custom/bootstrap_sp/
chmod +x ./deploy.sh
./deploy.sh

# Fetch SP info to local env variables from Terraform output once it's run through
SERVICE_PRINCIPAL_NAME=$(terraform show -json terraform.tfstate | jq -r .values.outputs.bootstrap_ARM_CLIENT_ID.value)
CLIENT_SECRET=$(terraform show -json terraform.tfstate | jq -r .values.outputs.bootstrap_ARM_CLIENT_SECRET.value)
SUBSCRIPTION_ID=$(terraform show -json terraform.tfstate | jq -r .values.outputs.bootstrap_ARM_SUBSCRIPTION_ID.value)
TENANT_ID=$(terraform show -json terraform.tfstate | jq -r .values.outputs.bootstrap_ARM_TENANT_ID.value)
```

 **Notes: This bootstrap script creates**
 - Service Principal with Contributor role on subscription level (RBAC)
 - Assigns the Azure AD Application Developer role for the SP
 - Gives a bunch of API permissions and grants those
 - Creates also a custom RBAC role scoped to your Azure subscription for some more fine grained RBAC permissions needed for provisioning the Launchpad's resources as well as the LZ (modify policies)
 
 **why?** so that we don't have to grant it _Owner_ permissions to subscription level

## Configure Azure Pipeline

*From Rover (Dev Container)*

```bash
# Navigate to custom repo root in Rover container context
cd /tf/caf-custom

# Login to Azure DevOps - providing the PAT token created previously (1. time)
az devops login

# Prepare your environment
AZURE_DEVOPS_ORGANIZATION='<your-azure-devops-organization>'
AZURE_DEVOPS_ACCOUNT='https://dev.azure.com/<your-azure-devops-organization>/'
AZURE_DEVOPS_PROJECT='testing-caf-landingzones'

az devops configure --defaults organization="$AZURE_DEVOPS_ACCOUNT" project="$AZURE_DEVOPS_PROJECT"

# Create new Project to ADO
az devops project create --name "$AZURE_DEVOPS_PROJECT"

# Import this repo to ADO Project's default git repo
az repos import create --git-url https://github.com/Masahigo/caf-terraform-landingzone-example.git --repository "$AZURE_DEVOPS_PROJECT"

# Paste PAT (2. time)
AZURE_DEVOPS_PAT=<your-PAT>
# Clone the imported Azure repo
# https://github.com/MicrosoftDocs/azure-devops-docs/issues/2455#issuecomment-439503194
git clone https://anything:$AZURE_DEVOPS_PAT@dev.azure.com/$AZURE_DEVOPS_ORGANIZATION/$AZURE_DEVOPS_PROJECT/_git/$AZURE_DEVOPS_PROJECT /tf/caf-custom

# Create the CD pipeline 
# Using DEV environment as an example here
PIPELINE_NAME='dev.lz.cd'
PIPELINE_DESCRIPTION='DEV Landing Zone example - Continuous Delivery'
REPO_YAML_PATH='pipelines/dev/azure-pipelines.yml'
FOLDER_PATH='\pipelines\dev'

az pipelines folder create --path "$FOLDER_PATH"

az pipelines create --name "$PIPELINE_NAME" \
    --description "$PIPELINE_DESCRIPTION" \
    --repository "$AZURE_DEVOPS_PROJECT" \
    --repository-type tfsgit \
    --branch master \
    --yml-path "$REPO_YAML_PATH" \
    --folder-path "$FOLDER_PATH" \
    --skip-first-run

# Store SP's credentials to ADO variables
az pipelines variable create --name ARM_TENANT_ID --secret true --value $TENANT_ID --pipeline-name "$PIPELINE_NAME"
az pipelines variable create --name ARM_SUBSCRIPTION_ID --secret true --value $SUBSCRIPTION_ID --pipeline-name "$PIPELINE_NAME"
az pipelines variable create --name ARM_CLIENT_ID --secret true --value $SERVICE_PRINCIPAL_NAME --pipeline-name "$PIPELINE_NAME"
az pipelines variable create --name ARM_CLIENT_SECRET --secret true --value $CLIENT_SECRET --pipeline-name "$PIPELINE_NAME"

# Trigger new pipeline run manually
az pipelines run --name $PIPELINE_NAME
```

**Clean up**

```bash
# Remove the resources created through pipeline
az pipelines run --name $PIPELINE_NAME --variable "DESTROY=true"

# Remove ADO Project
az devops project delete --id $(az devops project show -p "$AZURE_DEVOPS_PROJECT" --query id -o tsv) -y

# Remove bootstrap SP
cd /tf/caf-custom/bootstrap_sp/
terraform destroy -auto-approve
```
