data "aws_caller_identity" "this" {}
data "aws_region" "current" {}

resource "aws_iam_role" "lambda_exec_role" {
  name = "mlops-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_start_glue" {
  name = "lambda-start-glue"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["glue:StartJobRun"],
      Resource = "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.this.account_id}:job/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_start_glue_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_start_glue.arn
}

