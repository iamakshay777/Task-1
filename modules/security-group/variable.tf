# modules/security/variables.tf - Security module variables

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}