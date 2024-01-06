packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "gitlab_access_token" {}

source "amazon-ebs" "ubuntu" {
  ami_name      = "api-ami-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "api-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "set -x",
      "echo Installing the application",
      "sleep 30",
      "sudo apt update",
      "sudo apt install -y nodejs",
      "sudo apt install -y npm",
      "sudo apt install -y git",
      "wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb",
      "sudo dpkg -i -E ./amazon-cloudwatch-agent.deb",
      "git clone https://Sandip-kumar:${var.gitlab_access_token}@github.com:SandipKumar05/terraform-3-tier-app-aws.git",
      "cd /home/ubuntu/Sandip-kumar/app/api",
      "sudo npm install"
    ]
  }
}
