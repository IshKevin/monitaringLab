variable "project_name" {
  description = "Name of the project (used for tagging and naming resources)"
  type        = string
  default     = "cicd-project"
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Port where the Flask app will run"
  type        = number
  default     = 5000
}

variable "jenkins_port" {
  description = "Port for Jenkins UI"
  type        = number
  default     = 8080
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instances"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_app_cidr" {
  description = "CIDR block allowed to access the app"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_jenkins_cidr" {
  description = "CIDR block allowed to access Jenkins UI"
  type        = string
  default     = "0.0.0.0/0"
}