resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "monitoringlab-cloudtrail-logs"
}

resource "aws_cloudtrail" "main" {
  name           = "monitoring-trail"
  s3_bucket_name = module.cloudtrail_bucket.bucket_id

  depends_on = [
    module.cloudtrail_bucket
  ]

  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}