resource "aws_sns_topic" "email_notifications" {
  name = "email-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.email_notifications.arn
  protocol  = "email"
  endpoint  = var.email
}

module "canary_infra" {
  source     = "./modules/canary-infra"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
}

module "canary_web" {
  source            = "./modules/canary"
  name              = "web-url"
  take_screenshot   = "false"
  runtime_version   = "syn-nodejs-puppeteer-3.7"
  api_hostname      = aws_lb.application-load-balancer.dns_name
  api_path          = "/"
  reports-bucket    = module.canary_infra.reports-bucket
  role              = module.canary_infra.role
  security_group_id = module.canary_infra.security_group_id
  subnet_ids        = module.vpc.public_subnets
  frequency         = 5
  alert_sns_topic   = aws_sns_topic.email_notifications.arn
}

module "canary_api" {
  source            = "./modules/canary"
  name              = "api-url"
  take_screenshot   = "false"
  runtime_version   = "syn-nodejs-puppeteer-3.7"
  api_hostname      = aws_lb.application-load-balancer.dns_name
  api_path          = "/api/status"
  reports-bucket    = module.canary_infra.reports-bucket
  role              = module.canary_infra.role
  security_group_id = module.canary_infra.security_group_id
  subnet_ids        = module.vpc.public_subnets
  frequency         = 5
  alert_sns_topic   = aws_sns_topic.email_notifications.arn
}

module "monthly_billing_alert" {
  source = "binbashar/cost-billing-alarm/aws"

  aws_env                   = var.env
  aws_account_id            = var.aws_account_id
  monthly_billing_threshold = 100
  currency                  = "USD"
}

module "aws-rds-alarms" {
  source                                    = "lorenzoaiello/rds-alarms/aws"
  db_instance_id                            = aws_db_instance.database-instance.id
  actions_alarm                             = [aws_sns_topic.email_notifications.arn]
  actions_ok                                = [aws_sns_topic.email_notifications.arn]
  db_instance_class                         = var.database-instance-class
  disk_free_storage_space_too_low_threshold = "5000000000"
}

resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "web_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web-asg.name
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-asg.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_up.arn]
}

resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "web_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web-asg.name
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-asg.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_down.arn]
}