# Set an account-wide policy to block S3 public access:
resource "aws_s3_account_public_access_block" "account_pab" {
  count = var.disable_account_bpa ? 0 : 1

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
