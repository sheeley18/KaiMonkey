# ---------------------------------------------------------
# Misconfigured VPC
# - No VPC flow logs
# - Public subnet auto-assigns public IPs
# - Default NACL allows all inbound/outbound
# - No network segmentation
# ---------------------------------------------------------

resource "aws_vpc" "km_insecure_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  # No flow logs enabled

  tags = merge(var.default_tags, {
    Name = "km_insecure_vpc_${var.environment}"
  })
}

resource "aws_subnet" "km_insecure_public_subnet" {
  vpc_id                  = aws_vpc.km_insecure_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = merge(var.default_tags, {
    Name = "km_insecure_public_subnet_${var.environment}"
  })
}

resource "aws_subnet" "km_insecure_public_subnet_b" {
  vpc_id                  = aws_vpc.km_insecure_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = merge(var.default_tags, {
    Name = "km_insecure_public_subnet_b_${var.environment}"
  })
}

resource "aws_internet_gateway" "km_insecure_igw" {
  vpc_id = aws_vpc.km_insecure_vpc.id

  tags = merge(var.default_tags, {
    Name = "km_insecure_igw_${var.environment}"
  })
}

# Default NACL - allows all traffic in and out
resource "aws_default_network_acl" "km_insecure_nacl" {
  default_network_acl_id = aws_vpc.km_insecure_vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.default_tags, {
    Name = "km_insecure_nacl_${var.environment}"
  })
}
