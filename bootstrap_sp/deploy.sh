#!/bin/bash

pwd
source ./scripts/check_session.sh

echo ""
echo "Login with a Global Administrator user account:"
echo ""

check_session

echo "Starting ${tf_command} in"
echo " - tenant:          ${tenant}"
echo " - subscription ID: ${subscriptionId}"
echo ""

terraform init
terraform apply -auto-approve
