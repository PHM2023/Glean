# First, read the image digest from central first to know if we should rerun the preprocess script below due to a new
# digest. This is important because we might be pushing the same tag, but the digest can be different (i.e. for
# latest/master deploys)
module "central_dedicated_image" {
  source      = "../image_uri"
  repo_name   = var.repo_name
  version_tag = var.version_tag
}

# Then, run our custom script to download the image from central and re-upload the regional, account-specific ecr
resource "null_resource" "preprocess_dedicated_image" {
  provisioner "local-exec" {
    command = "python ${path.module}/scripts/preprocess_dedicated_image.py"
    # Environment vars are preferred over cmd line args to avoid injections
    environment = {
      REPO_NAME   = var.repo_name,
      VERSION_TAG = var.version_tag,
      ACCOUNT_ID  = var.account_id,
      REGION      = var.region
    }
  }
  triggers = {
    # We need to trigger on both the tag and image digest (uri) to handle both of the following cases:
    # - we're pushing the same tag but the digest has changed (usually with latest/master deploys)
    # - we're pushing a new tag but the digest is the same (for images that rarely change in the release)
    version_tag = var.version_tag,
    image_uri   = module.central_dedicated_image.image_uri,
    region      = var.region,
    account_id  = var.account_id
  }
}

# Finally, read the new image digest from the regional, account-specific ecr
module "regional_dedicated_image" {
  source      = "../image_uri"
  repo_name   = var.repo_name
  version_tag = var.version_tag
  region      = var.region
  registry    = var.account_id
  depends_on  = [null_resource.preprocess_dedicated_image]
}
