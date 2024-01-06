variable "env" {
  description = "env staging/production etc"
  type        = string
}

variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  description = "VPC_cidr block"
  type        = string
}

variable "vpc_azs" {
  default     = ["us-east-1a", "us-east-1b"]
  description = "vpc azs"
  type        = list(string)
}

variable "public-subnet-cidr" {
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "public cidr"
  type        = list(string)
}

variable "private-subnet-cidr" {
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "private cidr"
  type        = list(string)
}

variable "database-subnet-cidr" {
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
  description = "private cidr"
  type        = list(string)
}

variable "database-instance-class" {
  default     = "db.t3.micro"
  description = "The Database Instance type"
  type        = string
}

variable "database-user" {
  default     = "sandip"
  description = "The Database user name"
  type        = string
}

variable "database-password" {
  default     = "qwerty123"
  description = "The Database password"
  type        = string
}

variable "database-version" {
  default     = "15.4"
  description = "database version"
  type        = string
}

variable "database-db-name" {
  default     = "postgres"
  description = "db in Database "
  type        = string
}

variable "multi-az-deployment" {
  default     = false
  description = "Create a Standby DB Instance"
  type        = bool
}

variable "web-service-port" {
  default     = "3000"
  description = "The Database Instance type"
  type        = string
}

variable "api-service-port" {
  default     = "3001"
  description = "The Database Instance type"
  type        = string
}

variable "ssh-locate" {
  default     = "58.84.60.100/30"
  description = "my laptop ip address"
  type        = string
}

variable "email" {
  default     = "sandipgupta05@gmail.com"
  description = "my personal email"
  type        = string
}

variable "aws_account_id" {
  default     = "313083483414"
  description = "account id"
  type        = string
}

variable "key_name" {
  description = "key name"
  type        = string
}

variable "instance_type" {
  default     = "t2.micro"
  description = "key name"
  type        = string
}