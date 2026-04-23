variable "name" {
  description = "Instance name"
  type        = string
}

variable "instance_type" {
  type = string
}

variable "app_port" {
  default = 5000
}

variable "enable_jenkins" {
  default = false
}