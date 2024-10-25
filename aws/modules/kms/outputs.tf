output "query_secret_object_key" {
  value = aws_s3_object.query_service_secret_object.key
}

output "secret_store_key_arn" {
  value = aws_kms_key.secret_store_key.arn
}

output "ipjc_signing_key_arn" {
  value = aws_kms_key.ipjc_signing_key.arn
}

output "storage_secrets_key_arn" {
  value = aws_kms_key.secrets_key.arn
}

output "ipjc_signing_key_sign_policy_arn" {
  value = aws_iam_policy.ipjc_signing_key_sign_policy.arn
}

output "secret_store_cryptor_policy_arn" {
  value = aws_iam_policy.secret_store_key_cryptor_policy.arn
}

output "ipjc_signing_key_get_public_key_policy_arn" {
  value = aws_iam_policy.ipjc_signing_key_get_public_key_policy.arn
}

output "slackbot_key_get_public_key_policy_arn" {
  value = aws_iam_policy.slack_bot_key_get_public_key_policy.arn
}

output "slackbot_key_arn" {
  value = aws_kms_key.slack_bot_key.arn
}

output "tools_key_arn" {
  value = aws_kms_key.tools_signing_key.arn
}

output "query_secret_key_cryptor_policy_arn" {
  value = aws_iam_policy.query_secrets_key_cryptor_policy.arn
}

output "secret_store_key_id" {
  value = aws_kms_key.secret_store_key.id
}
