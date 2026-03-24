# ---------------------------------------------------------
# Misconfigured RDS Instance
# - Publicly accessible
# - No encryption at rest
# - No backups (retention = 0)
# - No multi-AZ
# - No deletion protection
# - Hardcoded credentials (admin/password123)
# - No IAM authentication
# - No enhanced monitoring or performance insights
# - Security group open on all TCP ports to 0.0.0.0/0
# ---------------------------------------------------------

resource "aws_security_group" "km_insecure_rds_sg" {
  name   = "km_insecure_rds_sg_${var.environment}"
  vpc_id = aws_vpc.km_insecure_vpc.id

  # Allow ALL inbound traffic on all ports
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    Name = "km_insecure_rds_sg_${var.environment}"
  })
}

resource "aws_db_subnet_group" "km_insecure_db_subnet" {
  name       = "km-insecure-db-subnet-${var.environment}"
  subnet_ids = [
    aws_subnet.km_insecure_public_subnet.id,
    aws_subnet.km_insecure_public_subnet_b.id,
  ]

  tags = merge(var.default_tags, {
    Name = "km_insecure_db_subnet_${var.environment}"
  })
}

resource "aws_db_instance" "km_insecure_db" {
  identifier                = "km-insecure-db-${var.environment}"
  allocated_storage         = 20
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  username                  = "admin"
  password                  = "password123"

  # Publicly accessible
  publicly_accessible       = true

  # No encryption
  storage_encrypted         = false

  # No backups
  backup_retention_period   = 0

  # No multi-AZ
  multi_az                  = false

  # No deletion protection
  deletion_protection       = false

  # Skip final snapshot
  skip_final_snapshot       = true

  # No IAM authentication
  iam_database_authentication_enabled = false

  # No enhanced monitoring
  # No performance insights
  # No auto minor version upgrade
  auto_minor_version_upgrade = false

  vpc_security_group_ids    = [aws_security_group.km_insecure_rds_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.km_insecure_db_subnet.name

  tags = merge(var.default_tags, {
    Name = "km_insecure_db_${var.environment}"
  })
}
