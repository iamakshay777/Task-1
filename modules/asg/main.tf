# modules/asg/main.tf - Auto Scaling Group module

# Create launch template for EC2 instances
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null
  
  # Network configuration
  vpc_security_group_ids = [var.security_group_id]
  
  # IAM Instance Profile
  iam_instance_profile {
    name = var.iam_instance_profile
  }
  
  # Block device mappings for EBS volumes
  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }
  
  # Monitoring - enable detailed monitoring
  monitoring {
    enabled = true
  }
  
  # User data script to set up application
  user_data     = base64encode(<<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd

    cat <<EOT > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
    <head>
      <title>Hello</title>
    </head>
    <body>
      <h1>Testing Task1!</h1>
    </body>
    </html>
    EOT
  EOF 
  )
  
  # Tags for instances
  tag_specifications {
    resource_type = "instance"
    
    tags = {
      Name = "${var.project_name}-${var.environment}-app"
    }
  }
  
  # Tags for volumes
  tag_specifications {
    resource_type = "volume"
    
    tags = {
      Name = "${var.project_name}-${var.environment}-app-volume"
    }
  }
  
  # Use the latest version always
  update_default_version = true
  
  # Ensure instance metadata is accessible securely
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  
  # Enable termination protection for production instances
  disable_api_termination = var.environment == "prod" ? true : false
  
  lifecycle {
    create_before_destroy = true
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = var.target_group_arns
  
  # Launch template configuration
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  
  # Desired capacity settings
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300
  
  # Termination policies
  termination_policies = ["OldestLaunchTemplate", "OldestInstance"]
  
  # Wait for instances to be fully configured on updates
  wait_for_capacity_timeout = "10m"
  
  # Instance Maintenance Policy - instance refresh settings
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 300
    }
    triggers = ["tag"]
  }
  
  # Enable metrics collection
  metrics_granularity = "1Minute"
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
  
  # Use instance protection if it's production
  protect_from_scale_in = var.environment == "prod" ? true : false
  
  # Tags for ASG - must use this special format for ASG
  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg"
    propagate_at_launch = false
  }
  
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = false
  }
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Create scale-out policy
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project_name}-${var.environment}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# Create scale-in policy
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project_name}-${var.environment}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# Create CPU high alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
  
  alarm_description = "Scale out if CPU > 80% for 2 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_out.arn]
}

# Create CPU low alarm
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
  
  alarm_description = "Scale in if CPU < 20% for 2 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_in.arn]
}