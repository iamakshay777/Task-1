# AWS Infrastructure Deployment with Terraform

This repository contains Terraform code to deploy a robust AWS infrastructure including VPC, subnets, security groups, EC2 instances, EBS volumes, and more.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration Options](#configuration-options)
- [Modules](#modules)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

This Terraform project automates the deployment of an AWS infrastructure environment, creating a complete network setup with compute resources. The infrastructure is designed for high availability, security, and follows AWS best practices.

Key components provisioned:
- **VPC** with public and private subnets across multiple Availability Zones
- **EC2 instances** for application and database servers
- **Security Groups** with proper inbound and outbound rules
- **Internet Gateway** and **NAT Gateway** for network connectivity
- **IAM Roles** with appropriate permissions

## Architecture

The architecture follows a multi-tier design with:
- Public subnets for internet-facing resources
- Private subnets for backend services
- Secure cross-AZ communication
- Controlled internet access through NAT Gateway

## Prerequisites

Before using this Terraform code, ensure you have:

1. **Terraform** installed (version 1.0.0 or later)
2. **AWS CLI** installed and configured with appropriate credentials
3. An **AWS Account** with permissions to create the resources
4. **Git** for cloning this repository

## Project Structure

```
.
├── main.tf                    # Main Terraform configuration file
├── variables.tf               # Input variables declaration
├── outputs.tf                 # Output values configuration
├── provider.tf                # AWS provider configuration
├── ec2.tf                     # EC2 instance configurations
├── vpc.tf                     # VPC and networking configurations
├── security_groups.tf         # Security group rules and configurations
└── terraform.tfvars.example   # Example variable values (rename to terraform.tfvars for use)
```

## Getting Started

Follow these steps to deploy the infrastructure:

### 1. Clone the Repository

```bash
git clone https://github.com/iamakshay777/Task-1.git
cd Task-1
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review and Configure Variables

Copy the example variables file and modify as needed:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your preferred configuration values.

### 4. Plan the Deployment

```bash
terraform plan
```

Review the execution plan to ensure it aligns with your expectations.

### 5. Apply the Configuration

```bash
terraform apply
```

Enter `yes` when prompted to confirm deployment.

### 6. Clean Up Resources

When you no longer need the infrastructure:

```bash
terraform destroy
```

## Configuration Options

The following variables can be customized in `terraform.tfvars`:

| Variable Name | Description | Default Value |
|---------------|-------------|---------------|
| `region` | AWS region to deploy resources | `us-east-1` |
| `vpc_cidr` | CIDR block for the VPC | `10.0.0.0/16` |
| `public_subnet_cidrs` | List of public subnet CIDR blocks | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | List of private subnet CIDR blocks | `["10.0.3.0/24", "10.0.4.0/24"]` |
| `instance_type` | EC2 instance size | `t2.micro` |
| `volume_size` | Size of EBS volumes in GB | `20` |
| `environment` | Deployment environment tag | `dev` |

## Modules

The infrastructure is organized into logical components:

### VPC and Networking
- Creates a VPC with configurable CIDR
- Sets up public and private subnets across availability zones
- Configures Internet Gateway and route tables
- Establishes NAT Gateway for private subnet internet access

### EC2 Instances
- Provisions EC2 instances with the specified AMI and instance type
- Attaches IAM roles with appropriate permissions
- Configures security groups and network interfaces

### Security
- Implements security groups with least-privilege access
- Sets up network ACLs for additional network security
- Configures SSH key pairs for secure instance access

## Best Practices

This Terraform code incorporates several best practices:

1. **Resource Tagging** - All resources are systematically tagged for better organization and cost tracking
2. **Code Modularization** - Logical separation of resources into different configuration files
3. **Variable Parameterization** - Key configuration values are parameterized for flexibility
4. **Security First** - Security groups follow principle of least privilege
5. **High Availability** - Resources are deployed across multiple availability zones
6. **State Management** - Recommended setup for remote state storage (see `backend.tf.example`)
7. **Conditional Resources** - Some resources are conditionally created based on environment needs

## Troubleshooting

Common issues and solutions:

### Deployment Failures
- Ensure your AWS credentials have sufficient permissions
- Check for service quotas that might limit resource creation
- Verify that your selected region supports all required resource types

### Connectivity Issues
- Confirm security group rules allow necessary traffic
- Verify route table configurations for proper routing
- Check NAT Gateway setup for private subnet internet access
