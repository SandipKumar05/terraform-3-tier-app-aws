resource "aws_security_group" "ssh-security-group" {
  name        = "SSH Access"
  description = "Enable ssh access on port 22"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # cidr_blocks = ["${var.ssh-locate}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh Security group"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh-security-group.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.dev-resources-iam-profile.name
  tags = {
    Name = "bastion"
  }
}

resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.dev-resources-iam-role.name
}

resource "aws_iam_role" "dev-resources-iam-role" {
  name               = "dev-ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<-EOF
                        {
                          "Version": "2012-10-17",
                          "Statement": {
                            "Effect": "Allow",
                            "Principal": {
                              "Service": "ec2.amazonaws.com"
                            },
                            "Action": "sts:AssumeRole"
                          }
                        }
                        EOF
  tags = {
    stack = "test"
  }
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}