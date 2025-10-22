resource "aws_glue_job" "clean_data" {
  name     = "clean-data-job"
  role_arn = var.glue_role_arn

  command {
    name            = "glueetl"
    script_location = "s3://${var.raw_bucket_name}/scripts/clean_data.py"
    python_version  = "3"
  }

  glue_version = "4.0"
  max_retries  = 0
  timeout      = 10
}
