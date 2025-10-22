resource "aws_lambda_function" "trigger_pipeline" {
  function_name = "trigger-pipeline"
  handler       = "trigger_pipeline.lambda_handler"
  runtime       = "python3.11"
  role          = var.lambda_role_arn

  filename         = "lambda_package.zip"
  source_code_hash = filebase64sha256("lambda_package.zip")

  environment {
    variables = {
      GLUE_JOB_NAME = var.glue_job_name
    }
  }
}

# Allow S3 to invoke Lambda (optional now; add if you want S3->Lambda trigger)
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_pipeline.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.raw_bucket_name}"
}
