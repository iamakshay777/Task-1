# modules/security/main.tf - Security module

# Security group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = var.vpc_id
  
  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }
  
  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
  
  # Lifecycle policy to prevent accidental deletion
  lifecycle {
    create_before_destroy = true
  }
}

# Security group for application instances
resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for application instances"
  vpc_id      = var.vpc_id
  
  # Allow traffic only from ALB security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow HTTP traffic from ALB"
  }
  
  # Allow SSH from a bastion host (if needed)
  # This would typically be limited to a specific CIDR block
  # or security group in a production environment
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"] # Replace with your bastion host CIDR
    description     = "Allow SSH from bastion host"
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-app-sg"
  }
  
  # Lifecycle policy to prevent accidental deletion
  lifecycle {
    create_before_destroy = true
  }
}