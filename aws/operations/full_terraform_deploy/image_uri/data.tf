# Gets the full digest of the image.
# Note: unfortunately, terraform needs ecr:DescribeRepositories when fetching images using the aws_ecr_image data block.
# We'd prefer not to grant this on our repos, so instead we get the image digest using boto3
data "external" "image_uri" {
  program = ["python", "${path.module}/scripts/get_image_uri.py"]
  query = {
    "version_tag" : var.version_tag,
    # tf requires that each arg set in the query is a string
    "repo_name" : var.repo_name,
    "region" : var.region,
    "registry" : var.registry
  }
}
