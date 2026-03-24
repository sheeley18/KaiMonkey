# ---------------------------------------------------------
# Severely misconfigured S3 bucket
# - Public read-write ACL
# - No versioning
# - No server-side encryption
# - No logging or lifecycle rules
# - All public access protections disabled
# - Bucket policy grants * full read/write/delete
# ---------------------------------------------------------

resource "aws_s3_bucket" "km_badly_configured_bucket" {
  bucket = "km-badly-configured-${var.environment}"
  acl    = "public-read-write"

  versioning {
    enabled = false
  }

  # No server-side encryption
  # No logging
  # No lifecycle rules

  tags = merge(var.default_tags, {
    Name = "km_badly_configured_${var.environment}"
  })
}

resource "aws_s3_bucket_public_access_block" "km_badly_configured_bucket" {
  bucket = aws_s3_bucket.km_badly_configured_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "km_badly_configured_bucket_policy" {
  bucket = aws_s3_bucket.km_badly_configured_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject", "s3:ListBucket"]
        Resource  = [
          aws_s3_bucket.km_badly_configured_bucket.arn,
          "${aws_s3_bucket.km_badly_configured_bucket.arn}/*"
        ]
      },
      {
        Sid       = "AllowPublicWrite"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:PutObject", "s3:DeleteObject"]
        Resource  = "${aws_s3_bucket.km_badly_configured_bucket.arn}/*"
      }
    ]
  })
}
