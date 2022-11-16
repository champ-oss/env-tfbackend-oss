locals {
  protect = true
  name    = var.git
  tags = {
    git     = var.git
    creator = "terraform"
    cost    = "shared"
  }
}

resource "aws_s3_bucket" "backend" {
  bucket        = "${local.name}-backend"
  tags          = local.tags
  force_destroy = !local.protect

  # required to support idempotent execution without a pre-existing backend
  lifecycle {
    ignore_changes = [acl, force_destroy]
  }
}

resource "aws_s3_bucket_acl" "backend" {
  bucket = aws_s3_bucket.backend.id
  acl    = "private"
}

resource "aws_s3_bucket_logging" "backend" {
  bucket        = aws_s3_bucket.backend.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "${local.name}-backend"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = aws_s3_bucket.backend.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "backend" {
  bucket                  = aws_s3_bucket.backend.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket" "logs" {
  bucket        = "${local.name}-logs"
  tags          = local.tags
  force_destroy = !local.protect

  # required to support idempotent execution without a pre-existing backend
  lifecycle {
    ignore_changes = [acl, force_destroy, grant]
  }
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}