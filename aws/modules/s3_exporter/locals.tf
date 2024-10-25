module "s3_exports" {
  source = "../../../common/logging_sinks"
}

locals {
  s3_exports = keys(module.s3_exports.storage_log_sinks)
}
