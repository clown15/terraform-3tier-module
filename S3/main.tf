resource "aws_s3_bucket" "s3" {
  bucket = "${var.company}-s3-${var.env}-${var.bucket_name}-apne2"
  tags = {
    Name = "${var.company}-s3-${var.env}-${var.bucket_name}-apne2"
  }
  force_destroy = true # terraform destroy시 버킷 강제 삭제
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.s3.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_public_block" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.s3.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "Statement1",
        Effect : "Allow",
        Principal : "*",
        Action : "s3:Get*",
        Resource : "${aws_s3_bucket.s3.arn}/*"
      }
    ]
  })
}