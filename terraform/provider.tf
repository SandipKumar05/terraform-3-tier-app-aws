terraform {
  required_version = "~> 1.6.6"
  required_providers {
    aws = {
      version = "~> 5.31.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-tfstate-demo"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Owner   = "sandip"
      Project = "demo"
    }
  }
}