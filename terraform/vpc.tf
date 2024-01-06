module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.env}-demo-vpc"
  cidr = var.vpc_cidr

  azs              = var.vpc_azs
  public_subnets   = var.public-subnet-cidr
  private_subnets  = var.private-subnet-cidr
  database_subnets = var.database-subnet-cidr

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "${var.env}"
  }
}