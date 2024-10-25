data "aws_iam_policy" "basic_lambda_role" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "lambda_vpc_access_execution_role" {
  name = "AWSLambdaVPCAccessExecutionRole"
}