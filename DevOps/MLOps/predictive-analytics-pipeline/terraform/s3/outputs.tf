output "raw_bucket_name" {
  value = aws_s3_bucket.mlops_raw.bucket
}

output "processed_bucket_name" {
  value = aws_s3_bucket.mlops_processed.bucket
}

output "model_bucket_name" {
  value = aws_s3_bucket.mlops_model.bucket
}
