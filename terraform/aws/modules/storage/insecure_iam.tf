# ---------------------------------------------------------
# Misconfigured IAM Resources
# - Role assumable by any AWS account (Principal: *)
# - Inline policy with Action: * on Resource: *
# - IAM user with console access and static credentials
# - No MFA enforcement
# - Overly permissive policies
# ---------------------------------------------------------

resource "aws_iam_role" "km_insecure_admin_role" {
  name = "km-insecure-admin-role-${var.environment}"

  # Assumable by anyone
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.default_tags, {
    Name = "km_insecure_admin_role_${var.environment}"
  })
}

resource "aws_iam_role_policy" "km_insecure_admin_policy" {
  name = "km-insecure-admin-policy-${var.environment}"
  role = aws_iam_role.km_insecure_admin_role.id

  # Full admin access - Action * on Resource *
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user" "km_insecure_user" {
  name = "km-insecure-user-${var.environment}"

  tags = merge(var.default_tags, {
    Name = "km_insecure_user_${var.environment}"
  })
}

resource "aws_iam_user_policy" "km_insecure_user_policy" {
  name = "km-insecure-user-policy-${var.environment}"
  user = aws_iam_user.km_insecure_user.name

  # Full admin - Action * on Resource *
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "km_insecure_user_key" {
  user = aws_iam_user.km_insecure_user.name
}

resource "aws_iam_user_login_profile" "km_insecure_user_login" {
  user                    = aws_iam_user.km_insecure_user.name
  password_reset_required = false
}
