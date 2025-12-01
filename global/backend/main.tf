#############################################
# S3 BUCKET FOR TERRAFORM REMOTE STATE
#############################################

resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name

  # Block public access at bucket level (recommended)
  force_destroy = false
}

#############################################
# ENABLE VERSIONING
#############################################

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

#############################################
# ENABLE ENCRYPTION (AES-256)
#############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.tf_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#############################################
# BLOCK ALL PUBLIC ACCESS
#############################################

resource "aws_s3_bucket_public_access_block" "tf_state_block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#############################################
# DYNAMODB TABLE FOR STATE LOCKING
#############################################

resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}
