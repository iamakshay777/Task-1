
# Create Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  
  
  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}



# Create target group for ALB
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  # Health check configuration
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-299"
  }
  
  
  tags = {
    Name = "${var.project_name}-${var.environment}-tg"
  }
  
  # Ensure proper dependencies
  depends_on = [aws_lb.main]
}

# Create HTTP listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  # Redirect to HTTPS in production (you would need to set up SSL certificates)
  # For simplicity, we'll just forward to the target group in this example
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}