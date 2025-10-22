
resource "aws_s3_bucket" "mlops_raw" {
  bucket = "mlops-predictive-raw-975628796846"
  tags   = { purpose = "mlops-raw" }
}

resource "aws_s3_bucket" "mlops_processed" {
  bucket = "mlops-predictive-processed-975628796846"
  tags   = { purpose = "mlops-processed" }
}

resource "aws_s3_bucket" "mlops_model" {
  bucket = "mlops-predictive-model-975628796846"
  tags   = { purpose = "mlops-model" }
}
