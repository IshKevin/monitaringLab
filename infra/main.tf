terraform {
  required_version = ">= 1.5.0"

  # backend "s3" {
  #   bucket         = "multicontainerlab-state-854fb003"
  #   key            = "state/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "terraform-lock"
  # }
}

module "jenkins" {
  source = "./modules/ec2"

  name           = "jenkins"
  instance_type  = var.instance_type
  enable_jenkins = true
}

module "app" {
  source = "./modules/ec2"

  name          = "app"
  instance_type = var.instance_type
}


# resource "local_file" "key_name" {
#     jenkins_ip = module.jenkins.public_ip
#     app_ip     = module.app.public_ip
#     key_path   = "../terraform/${module.jenkins.key_name}.pem"

# }