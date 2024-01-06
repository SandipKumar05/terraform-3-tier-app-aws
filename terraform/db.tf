resource "aws_security_group" "database-security-group" {
  name        = "Database server Security Group"
  description = "Enable PG access on port 5432"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PQ access"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app-security-group.id}", "${aws_security_group.ssh-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database Security group"
  }
}

resource "aws_db_subnet_group" "database-subnet-group" {
  name        = "database subnets"
  subnet_ids  = module.vpc.database_subnets
  description = "Subnet group for database instance"

  tags = {
    Name = "Database Subnets"
  }
}

resource "aws_db_instance" "database-instance" {
  identifier             = "api-postgresql"
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = var.database-version
  instance_class         = var.database-instance-class
  db_name                = var.database-db-name
  username               = var.database-user
  password               = var.database-password
  db_subnet_group_name   = aws_db_subnet_group.database-subnet-group.name
  multi_az               = var.multi-az-deployment
  vpc_security_group_ids = [aws_security_group.database-security-group.id]
}

# rds backup setup 
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backup_default_service_role" {
  name               = "AWSBackupDefaultServiceRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "backup_service_role_for_backup_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_default_service_role.name
}

resource "aws_backup_plan" "rds_instance_plan" {
  name = "rds-instance-daily-backup"

  rule {
    rule_name                = "rds-instance-daily-backup-rule"
    target_vault_name        = aws_backup_vault.rds_backup_vault.name
    schedule                 = "cron(0 12 * * ? *)"
    enable_continuous_backup = true

    lifecycle {
      delete_after = 7
    }
  }
}

resource "aws_backup_selection" "rds_instance_selection" {
  iam_role_arn = aws_iam_role.backup_default_service_role.arn
  name         = "rds-instance-daily-backup-selection"
  plan_id      = aws_backup_plan.rds_instance_plan.id

  resources = [
    aws_db_instance.database-instance.arn
  ]
}

resource "aws_backup_vault" "rds_backup_vault" {
  name        = "rds-backup-vault"
  kms_key_arn = aws_kms_key.rds_kms.arn
}

resource "aws_kms_key" "rds_kms" {
  description             = "RDS Backup KMS Key"
  deletion_window_in_days = 10
}