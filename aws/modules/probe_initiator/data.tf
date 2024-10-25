
data "aws_iam_policy" "basic_lambda_role" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "vpc_access_lambda_role" {
  name = "AWSLambdaVPCAccessExecutionRole"
}

