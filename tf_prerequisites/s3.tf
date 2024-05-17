resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = format("%s-tfstate", var.prefix)
  
  tags = {
    Name        = format("%s-tfstate", var.prefix)
    Environment = "Dev"
  }

  #lifecycle {
  #  prevent_destroy = true
  #}
}

resource "aws_s3_bucket" "tf_vars_bucket" {
  bucket = format("%s-tfvars", var.prefix)
  
  tags = {
    Name        = format("%s-tfvars", var.prefix)
    Environment = "Dev"
  }

  #lifecycle {
  #  prevent_destroy = true
  #}
}

resource "aws_s3_bucket_versioning" "versioning_tf_state_bucket" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encription_tf_state_bucket" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encription_tf_vars_bucket" {
  bucket = aws_s3_bucket.tf_vars_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_tf_state_bucket" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl_tf_state_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership_tf_state_bucket]

  bucket = aws_s3_bucket.tf_state_bucket.id
  acl    = "private"
}