resource "aws_s3_bucket" "website_assignment_bucket" {
  bucket = format("%s-website", var.prefix)

  force_destroy = true

  tags = {
    Name = format("%s-website", var.prefix)
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encription_website_assignment_bucket" {
  bucket = aws_s3_bucket.website_assignment_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_website_assignment_bucket" {
  bucket = aws_s3_bucket.website_assignment_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl_website_assignment_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership_website_assignment_bucket]
  bucket     = aws_s3_bucket.website_assignment_bucket.id
  acl        = "private"
}

resource "aws_s3_object" "html_files_website" {
  count  = 2
  bucket = aws_s3_bucket.website_assignment_bucket.bucket

  key    = var.html_files[count.index]
  source = format("./html_files/%s", var.html_files[count.index])
  acl    = "private"
}