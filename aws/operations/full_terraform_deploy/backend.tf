terraform {
  backend "s3" {
    bucket = "$terraform_bucket"
    # NOTE: a single/static dynamodb_table value can be used since the s3 backend can use a single table to lock
    # multiple state files: https://developer.hashicorp.com/terraform/language/settings/backends/s3
    # TODO: uncomment this after codebuild permissions are updated
    # dynamodb_table = "glean-terraform-state"
    key    = "$statefile_path"
    region = "$bucket_region"
  }
}
