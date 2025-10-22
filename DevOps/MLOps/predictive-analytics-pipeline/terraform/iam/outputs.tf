output "lambda_exec_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}

# keep this only if you actually created the Glue role in iam/glue.tf
output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}
