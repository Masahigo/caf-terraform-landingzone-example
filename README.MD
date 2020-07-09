# Introduction 
This Git repository is for a CAF Terraform Landing zone project. You can find more about the backgrounds [from here](https://github.com/Azure/caf-terraform-landingzones/tree/master/documentation).
Good place to start is by skim through [the intro](https://github.com/Azure/caf-terraform-landingzones/blob/master/documentation/code_architecture/intro_architecture.md). 

# Getting Started
We are using a tool called Rover. It's Dockerized and local development is done using VSCode and Dev Containers. Prerequisites for getting started [are listed here](https://github.com/aztfmod/rover#pre-requisites).

1.	[Installation process](https://github.com/Azure/caf-terraform-landingzones#getting-started)
2.	[Software dependencies](https://github.com/Azure/caf-terraform-landingzones#prerequisites)
3.	[Latest releases](https://hub.docker.com/r/aztfmod/rover/tags?page=1&ordering=last_updated)

# Local development

> **Windows 10 & WSL**: Make sure there is no ["time drift"](https://github.com/aztfmod/rover/issues/6) between your local computer time and the time in Docker containers. Before starting the Dev Container it's good to restart Docker Desktop before continuing.

> **Windows 10 & WSL2**: WSL2 also experiences from [similar issues](https://github.com/microsoft/WSL/issues/4245). To fix run `sudo hwclock -s`.

## 1. Initialize Rover in Dev Container from VSCode

```bash
[vscode@e1d53c1ca8ae ~]$ pwd
/home/vscode
```

## 2. Git checkout this repo from the container

```bash
[vscode@e1d53c1ca8ae ~]$ sudo mkdir /tf/caf-custom && sudo chown -R $(whoami) tf/caf-custom
[vscode@e1d53c1ca8ae ~]$ git clone https://github.com/Masahigo/caf-terraform-landingzone-example.git /tf/caf-custom
```

## 3. Login to Azure tenant and initialize Launchpad

```bash
[vscode@e1d53c1ca8ae ~]$ rover login
# Select subscription where Level 0 is provisioned
[vscode@e1d53c1ca8ae ~]$ az account set -s <your-subscription-id>
# Initialize Launchpad to WE (bootstrap level 0)
[vscode@e1d53c1ca8ae ~]$ rover /tf/caf/landingzones/launchpad apply -launchpad -var-file="/tf/caf-custom/tfvars/sandpit/launchpad_opensource_light.tfvars"

```

## 4. Start developing your Landing Zones!

```bash
# Deploy the Level 1 example LZ using Rover
[vscode@e1d53c1ca8ae ~]$ rover /tf/caf-custom/landingzones/level1_landingzone_example plan -var-file="/tf/caf-custom/tfvars/sandpit/level1_landingzone_example.tfvars"
[vscode@e1d53c1ca8ae ~]$ rover /tf/caf-custom/landingzones/level1_landingzone_example apply -var-file="/tf/caf-custom/tfvars/sandpit/level1_landingzone_example.tfvars"
[vscode@e1d53c1ca8ae ~]$ rover /tf/caf-custom/landingzones/level1_landingzone_example destroy -var-file="/tf/caf-custom/tfvars/sandpit/level1_landingzone_example.tfvars" --auto-approve
```

# File structure

```bash
bootstrap_sp

landingzones
├── level1_lanzingzone_example
|   landingzone.tf
|   main.tf
|   output.tf
|   variables.tf
|   versions.tf
├── ...

tfvars
├── ci
├── dev
├── sandpit
|   launchpad_opensource_light.tfvars
|   level1_landingzone_example.tfvars
├── environment_xyz
├── ...

pipelines
├── ci
|   azure_pipelines.yml
├── dev
|   azure_pipelines.yml
├── environment_xyz
├── ...
```

**bootstrap_sp**

This folder contains shell and Terraform scripts for creating the Service Principal account (level0-bootstrap-sp) needed for Rover in CI/CD.

```bash
cd /tf/caf-custom/bootstrap_sp/
chmod +x ./deploy.sh
./deploy.sh

# Fetch SP info from Terraform output once it's run through
ARM_TENANT_ID=$(terraform show -json terraform.tfstate | jq -r .values.outputs.bootstrap_ARM_TENANT_ID.value)
ARM_SUBSCRIPTION_ID=$(terraform show -json terraform.tfstate | jq -r .values.outputs.bootstrap_ARM_SUBSCRIPTION_ID.value)
ARM_CLIENT_ID=$(terraform show -json terraform.tfstate | jq -r .values.outputs.bootstrap_ARM_CLIENT_ID.value)
ARM_CLIENT_SECRET=$(terraform show -json terraform.tfstate | jq -r .values.outputs.bootstrap_ARM_CLIENT_SECRET.value)
```
