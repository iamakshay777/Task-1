# terraform.tfvars - Example variable values

# General
aws_region   = "us-east-1"
environment  = "prod"
project_name = "microservices-app"

# VPC
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

# EC2 and Auto Scaling Group
instance_type        = "t3.micro"
key_name             = "my-key-pair" # Set to your key pair name or leave empty
asg_min_size         = 2
asg_max_size         = 10
asg_desired_capacity = 2