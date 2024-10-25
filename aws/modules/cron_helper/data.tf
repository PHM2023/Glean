# TODO: We can still use a data block for this because currently this role is created in the bootstrap CFT (outside of
#  terraform). Eventually, we should move this into terraform as well
data "aws_iam_role" "deploy_build" {
  name = "deploy-build"
}
