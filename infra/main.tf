terraform {
  required_version = ">= 1.5.0"

  # backend "s3" {
  #   bucket         = "state-bucket"
  #   key            = "monitoringLab/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "terraform-lock"
  # }
   required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    random = {
      source  = "hashicorp/random"
    }
  }
}

provider "aws" {
  region = var.region
}

module "app" {
  source = "./modules/ec2"

  name          = "app-server"
  instance_type = var.instance_type
  app_port      = 5000
}


module "monitoring" {
  source = "./modules/ec2"

  name          = "monitoring-server"
  instance_type = var.instance_type
  app_port      = 9090
}


resource "random_id" "suffix" {
  byte_length = 4
}

module "cloudtrail_bucket" {
  source      = "./modules/bucket"
  bucket_name = "${var.project_name}-cloudtrail-logs-${random_id.suffix.hex}"
}


# resource "aws_cloudtrail" "main" {
#   name           = "monitoring-trail"
#   s3_bucket_name = module.cloudtrail_bucket.bucket_id

#   include_global_service_events = true
#   is_multi_region_trail         = true
#   enable_logging                = true
# }


# resource "aws_guardduty_detector" "main" {
#   enable = true
# }