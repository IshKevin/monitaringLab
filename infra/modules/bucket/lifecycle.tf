resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}