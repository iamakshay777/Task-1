# modules/iam/variables.tf - IAM module variables

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}