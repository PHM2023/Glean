# This account is supposed to be created in the context of the root account within which
# we create all the aws accounts

resource "aws_organizations_account" "account" {
  name  = var.account_name
  email = var.account_owner_email
}

# We need to create an alias for the account to make aws-nuke work
# aws-nuke allows nuking only the accounts that have an alias set
resource "aws_iam_account_alias" "alias" {
  account_alias = var.account_name
}
