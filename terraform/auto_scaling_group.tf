data "aws_ami" "api-latest-ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["api-ami-*"]
  }
}

data "aws_ami" "web-latest-ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["web-ami-*"]
  }
}

resource "aws_iam_instance_profile" "cloudwatch_instance_profile" {
  name = "cloudwatch_instance_profile"
  role = aws_iam_role.cloud-watch-agent-role.name
}

resource "aws_launch_template" "api-launch-template" {
  name_prefix   = "api-artifact-launch-template"
  image_id      = data.aws_ami.api-latest-ami.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.cloudwatch_instance_profile.name
  }
  network_interfaces {
    security_groups = [aws_security_group.app-security-group.id]
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -x
              export PORT=${var.api-service-port}
              export DBUSER=${var.database-user}
              export DBPASS=${var.database-password}
              export DBHOST=${aws_db_instance.database-instance.address}
              export DBPORT=5432
              export DB=${var.database-db-name}
              export cw_config="/home/ubuntu/Sandip-kumar/log-agent/api-cloudwatch-agent.json"
              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:$cw_config
              cd /home/ubuntu/Sandip-kumar/app/api
              npm start 2>&1 | tee /home/ubuntu/api.log
              EOF
  )
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    key   = "Name"
    value = "api node"
  }
}

resource "aws_autoscaling_group" "api-asg" {
  name                = "api-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = module.vpc.private_subnets
  launch_template {
    id      = aws_launch_template.api-launch-template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "api node"
    propagate_at_launch = true
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

resource "aws_launch_template" "web-launch-template" {
  name_prefix   = "web-artifact-launch-template"
  image_id      = data.aws_ami.web-latest-ami.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.cloudwatch_instance_profile.name
  }
  network_interfaces {
    security_groups             = [aws_security_group.app-security-group.id]
    associate_public_ip_address = true
  }
  user_data = base64encode(<<-EOF
            #!/bin/bash
            export PORT=${var.web-service-port}
            export API_HOST="http://${aws_lb.application-load-balancer.dns_name}"
            export CDN_HOST="https://${aws_cloudfront_distribution.cf_dist.domain_name}"
            export cw_config="/home/ubuntu/Sandip-kumar/log-agent/web-cloudwatch-agent.json"
            sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:$cw_config
            cd /home/ubuntu/Sandip-kumar/app/web
            npm start 2>&1 | tee /home/ubuntu/web.log
            EOF
  )

  tags = {
    key                 = "Name"
    value               = "web node"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                = "web-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = module.vpc.public_subnets
  launch_template {
    id      = aws_launch_template.web-launch-template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "web node"
    propagate_at_launch = true
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }
}

resource "aws_security_group" "app-security-group" {
  name        = "App server Security Group"
  description = "Enable http/https access on port 80/443 via ALB and ssh via ssh sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "http access"
    from_port       = 3000
    to_port         = 3001
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-security-group.id}"]
  }

  ingress {
    description     = "ssh access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ssh-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App server Security group"
  }
}
