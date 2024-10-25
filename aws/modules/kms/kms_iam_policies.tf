# IAM Policies for KMS keys

resource "aws_iam_policy" "secret_store_key_cryptor_policy" {
  name        = "GleanSecretStoreKeyEncryptorDecryptor"
  description = "Access to encrypt/decrypt values with the secret store kms key"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
        ],
        "Resource" : [
          aws_kms_key.secret_store_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "query_secrets_key_cryptor_policy" {
  name        = "GleanQuerySecretsKeyEncryptorDecryptor"
  description = "Access to encrypt/decrypt values with the query secrets key"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
        ],
        "Resource" : [
          aws_kms_key.secrets_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ipjc_signing_key_sign_policy" {
  name        = "GleanIPJCSigningKeySign"
  description = "Access to sign messages using the IPJC signing key"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Sign"
        ],
        "Resource" : [
          aws_kms_key.ipjc_signing_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ipjc_signing_key_get_public_key_policy" {
  name        = "GleanIPJCSigningKeyPublicKeyRead"
  description = "Access to get the public key for the ipjc signing key"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:GetPublicKey"
        ],
        "Resource" : [
          aws_kms_key.ipjc_signing_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "slack_bot_key_get_public_key_policy" {
  name        = "GleanSlackBotKeyPublicKeyRead"
  description = "Access get the public key for the slack bot signing key"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:GetPublicKey"
        ],
        "Resource" : [
          aws_kms_key.slack_bot_key.arn
        ]
      }
    ]
  })
}


