provider "aws" {
  region     = var.aws_region
  access_key = "<access-key>"
  secret_key = "<secret-key>"


  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  
    }
  }
   backend "s3" {
    bucket         = "myproject-prod1-tfstate"
    key            = "envs/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "myproject-prod1-tf-lock"
    encrypt        = true
  }
}
#create VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  project_name         = var.project_name
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

#s3 bucket creation

module "remote_state" {
  source          = "./modules/s3"
  bucket_name     = "myproject-prod1-tfstate"
  lock_table_name = "myproject-prod1-tf-lock"
  tags = {
    Environment = "dev"
    Owner       = "team-infra"
  }
}


#create ALB 
module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id
  environment       = var.environment
  project_name      = var.project_name
}


#create iam role
module "iam" {
  source = "./modules/iam"

  environment  = var.environment
  project_name = var.project_name
}


#creating ASG
module "asg" {
  source = "./modules/asg"

  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  security_group_id    = module.security_groups.app_security_group_id
  target_group_arns    = [module.alb.target_group_arn]
  iam_instance_profile = module.iam.instance_profile_name
  environment          = var.environment
  project_name         = var.project_name
  instance_type        = var.instance_type
  key_name             = var.key_name
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity
}



# Create security groups
module "security_groups" {
  source = "./modules/security-group"

  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
}