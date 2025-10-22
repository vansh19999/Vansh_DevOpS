# Grants Glue job read on RAW bucket (incl. scripts/) and write on PROCESSED bucket
resource "aws_iam_policy" "glue_s3_access" {
  name = "glue-s3-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "ListBuckets",
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : [
          "arn:aws:s3:::mlops-predictive-raw-975628796846",
          "arn:aws:s3:::mlops-predictive-processed-975628796846"
        ]
      },
      {
        "Sid" : "ReadRawObjects",
        "Effect" : "Allow",
        "Action" : ["s3:GetObject"],
        "Resource" : [
          "arn:aws:s3:::mlops-predictive-raw-975628796846/*"
        ]
      },
      {
        "Sid" : "WriteProcessedObjects",
        "Effect" : "Allow",
        "Action" : ["s3:PutObject"],
        "Resource" : [
          "arn:aws:s3:::mlops-predictive-processed-975628796846/*"
        ]
      }
    ]
  })
}

# Attach it to your existing Glue role (aws_iam_role.glue_role)
resource "aws_iam_role_policy_attachment" "glue_s3_access_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}
