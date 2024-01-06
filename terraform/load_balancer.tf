resource "aws_lb" "application-load-balancer" {
  name               = "external-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-security-group.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name = "App load balancer"
  }
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = 3000
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "api_target_group" {
  name     = "api-target-group"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    enabled             = true
    interval            = 30
    path                = "/api/status"
    port                = 3001
    protocol            = "HTTP"
    timeout             = 10 # seconds
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_attachment" "web_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web-asg.name
  lb_target_group_arn    = aws_lb_target_group.web_target_group.arn
}

resource "aws_autoscaling_attachment" "api_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.api-asg.name
  lb_target_group_arn    = aws_lb_target_group.api_target_group.arn
}

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.alb_http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  tags = {
    "Name" = "api"
  }
}

resource "aws_security_group" "alb-security-group" {
  name        = "ALB Security Group"
  description = "Enable http/https access on port 80/443"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security group"
  }
}