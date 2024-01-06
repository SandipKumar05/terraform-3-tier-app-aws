# Terraform Infrastructure Files for AWS

**AWS Region**: us-east-1

Use `staging.tfvars` to create the staging environment.

## File Structure

- **vpc.tf**: Creates a VPC with 2 private and 2 public subnets, Internet Gateway (IGW), Network Address Translation (NAT), route tables, Elastic IP (EIP) for NAT, etc.

- **bastion_ec2.tf**: Sets up a jump EC2 instance in the public subnet with the necessary security group.

- **auto_scaling_group.tf**: Creates two Auto Scaling Groups (ASGs) - one for the web and one for the API. Uses the latest API/web Amazon Machine Images (AMIs) in the launch template.

- **load_balancer.tf**: Configures an Internet-facing Load Balancer (LB) with required listener rules.
  - `http://<domain-name>/*` - To access the web interface.
  - `http://<domain-name>/api/*` - To access the API for this application.

- **db.tf**: Creates a PostgreSQL database in the private subnet.

- **cloudfront-cdn.tf**: Establishes an S3 bucket and CloudFront distribution for static content.

- **cloudwatch_alarm.tf**: Sets up alarms and auto-scaling trigger conditions.

- **staging.tfvars**: Configuration file to create/deploy resources in the staging environment.

- **production.tfvars**: Configuration file to create/deploy resources in the production environment.
