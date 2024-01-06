terraform {
  required_providers {
    aws = {
      version = "~> 5.31.0"
    }
  }
  required_version = "~> 1.6.6"
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "production"
      Owner       = "sandip"
      Project     = "demo"
    }
  }
}

resource "aws_s3_bucket" "s3_terraform_state" {
  bucket = "terraform-tfstate-demo"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_key_pair" "example" {
  key_name = "sandip"
  public_key = file("~/.ssh/id_rsa.pub")
}