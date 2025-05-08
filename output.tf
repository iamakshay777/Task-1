# outputs.tf - Output values

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the application load balancer"
  value       = module.alb.alb_zone_id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.asg_name
}

output "instance_security_group_id" {
  description = "Security group ID attached to instances"
  value       = module.security_groups.app_security_group_id
}

output "alb_security_group_id" {
  description = "Security group ID attached to ALB"
  value       = module.security_groups.alb_security_group_id
}

output "ec2_iam_role_name" {
  description = "Name of the IAM role attached to EC2 instances"
  value       = module.iam.ec2_role_name
}