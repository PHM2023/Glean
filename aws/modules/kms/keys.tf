# IPJC signing key and aliases
resource "aws_kms_key" "ipjc_signing_key" {
  description              = "For signing messages to Glean central deployment during IPJC"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_3072"
}

resource "aws_kms_alias" "ipjc_signing_key_alias_1" {
  name          = "alias/ipjc_signing_key"
  target_key_id = aws_kms_key.ipjc_signing_key.key_id
}

resource "aws_kms_alias" "ipjc_signing_key_alias_2" {
  # This one is for keeping parity with the gcp format of '<key ring>_<key name>'
  name          = "alias/scio-apps_signing-key"
  target_key_id = aws_kms_key.ipjc_signing_key.key_id
}

# Query secrets key and aliases
resource "aws_kms_key" "secrets_key" {
  description              = "Used for encrypting/decrypting the query service secret"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  rotation_period_in_days  = 90
}

resource "aws_kms_alias" "secrets_key_alias_1" {
  name          = "alias/secrets"
  target_key_id = aws_kms_key.secrets_key.key_id
}

resource "aws_kms_alias" "secrets_key_alias_2" {
  name          = "alias/storage_secrets"
  target_key_id = aws_kms_key.secrets_key.key_id
}

# Secret store key and aliases
resource "aws_kms_key" "secret_store_key" {
  description              = "Used for encrypting/decrypting values in secret store"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  rotation_period_in_days  = 90
}

resource "aws_kms_alias" "secret_store_key_alias_1" {
  name          = "alias/secret-store-key"
  target_key_id = aws_kms_key.secret_store_key.key_id
}

resource "aws_kms_alias" "secret_store_key_alias_2" {
  # This one is for keeping parity with the gcp format of '<key ring>_<key name>'
  name          = "alias/secret-store_secret-store-key"
  target_key_id = aws_kms_key.secret_store_key.key_id
}

# Slack bot key and alias
resource "aws_kms_key" "slack_bot_key" {
  description              = "For signing/verifying requests to/from slack event handler and QE"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "ECC_NIST_P256"
}

resource "aws_kms_alias" "slack_bot_key_alias" {
  target_key_id = aws_kms_key.slack_bot_key.key_id
  name          = "alias/slack-bot-key"
}

resource "aws_kms_alias" "slack_bot_key_alias_2" {
  target_key_id = aws_kms_key.slack_bot_key.key_id
  # This one is for keeping parity with the gcp format of '<key ring>_<key name>'
  name = "alias/storage_slack-bot-key"
}

# TODO: get these next two out of terraform
resource "random_password" "qp_secret_str" {
  length  = 32
  special = false
}

resource "aws_kms_ciphertext" "query_service_secret" {
  key_id    = aws_kms_key.secrets_key.key_id
  plaintext = "SECRET_SHOULD_NEVER_BE_LOGGED_${random_password.qp_secret_str.result}"
}

resource "aws_kms_key" "tools_signing_key" {
  description              = "For signing/verifying tools requests"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_3072"
}

resource "aws_kms_alias" "tools_signing_key_alias" {
  target_key_id = aws_kms_key.tools_signing_key.key_id
  name          = "alias/tools_signing-key"
}

locals {
  query_service_secret_hash      = substr(tostring(parseint(sha256(aws_kms_ciphertext.query_service_secret.ciphertext_blob), 16)), 0, 20)
  query_service_secret_file_name = "qp_secret.encrypted.${local.query_service_secret_hash}"
}

resource "aws_s3_object" "query_service_secret_object" {
  bucket         = var.query_secrets_bucket
  key            = local.query_service_secret_file_name
  content_base64 = aws_kms_ciphertext.query_service_secret.ciphertext_blob
  lifecycle {
    # Never change the query service secret in tf even if the ciphertext changes, this object should only be rotated
    # outside of terraform
    ignore_changes = [content_base64, key]
  }
}
