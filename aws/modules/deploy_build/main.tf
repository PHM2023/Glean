resource "aws_lambda_function" "deploy_build" {
  function_name = "deploy_build"
  description   = "Lambda used to run deployment operations for Glean installation"
  role          = data.aws_iam_role.deploy-build.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 900
  package_type  = "Image"
  memory_size   = 512
  environment {
    variables = {
      "allow_untrusted" : var.allow_untrusted_images ? "true" : "false"
    }
  }
}


resource "aws_iam_policy" "deploy_build_ecr_permissions" {
  name = "DeployBuildImageVerificationPermissions"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      # permissions needed to pull, inspect, and verify image signatures
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages",
        ],
        "Resource" : [
          "arn:aws:ecr:us-east-1:518642952506:repository/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "signer:ListSigningPlatforms",
          "signer:ListSigningProfiles",
          "signer:DescribeSigningJob",
          "signer:GetRevocationStatus",
          "signer:GetSigningPlatform",
          "signer:GetSigningProfile"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "deploy_build_vpc_permissions" {
  name = "DeployBuildVpcPermissions"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      # permissions needed to describe the vpc, subnets, and security groups used for codebuild
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ],
        "Resource" : [
          "*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "deploy_build_ecr_permissions_attachment" {
  policy_arn = aws_iam_policy.deploy_build_ecr_permissions.arn
  role       = data.aws_iam_role.deploy-build.name
}


resource "aws_iam_role_policy_attachment" "deploy_build_vpc_permissions_attachment" {
  policy_arn = aws_iam_policy.deploy_build_vpc_permissions.arn
  role       = data.aws_iam_role.deploy-build.name
}