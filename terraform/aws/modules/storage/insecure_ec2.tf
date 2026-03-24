# ---------------------------------------------------------
# Misconfigured EC2 Instance
# - Security group allows SSH (22) from 0.0.0.0/0
# - Security group allows all outbound
# - No IMDSv2 enforcement (metadata v1 enabled)
# - Unencrypted root EBS volume
# - Public IP assigned
# - Sensitive data in user_data (hardcoded secrets)
# - No detailed monitoring
# ---------------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "km_insecure_ec2_sg" {
  name   = "km_insecure_ec2_sg_${var.environment}"
  vpc_id = aws_vpc.km_insecure_vpc.id

  # SSH open to the world
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP open to the world
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS open to the world
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    Name = "km_insecure_ec2_sg_${var.environment}"
  })
}

resource "aws_instance" "km_insecure_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.km_insecure_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.km_insecure_ec2_sg.id]
  associate_public_ip_address = true

  # No IMDSv2 enforcement - metadata v1 exposed (SSRF risk)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  # Unencrypted root volume
  root_block_device {
    volume_size = 20
    encrypted   = false
  }

  # Hardcoded secrets in user_data (bad practice)
  user_data = <<-EOF
    #!/bin/bash
    export DB_HOST="km-insecure-db-${var.environment}.abcdef123456.us-east-1.rds.amazonaws.com"
    export DB_USER="admin"
    export DB_PASS="password123"
    export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
    export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    echo "Starting insecure application..."
  EOF

  # No detailed monitoring
  monitoring = false

  tags = merge(var.default_tags, {
    Name = "km_insecure_instance_${var.environment}"
  })
}

# Unencrypted EBS volume
resource "aws_ebs_volume" "km_insecure_volume" {
  availability_zone = "us-east-1a"
  size              = 50
  encrypted         = false

  tags = merge(var.default_tags, {
    Name = "km_insecure_volume_${var.environment}"
  })
}

resource "aws_volume_attachment" "km_insecure_volume_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.km_insecure_volume.id
  instance_id = aws_instance.km_insecure_instance.id
}
