# VPC configuration vars
variable "region" {}
variable "vpc_name" {}
variable "ami" {
  type = string
}
variable "vpc_tags" {}
variable "vpc_address" {}
variable "public_subnet_address" {
  type    = list(string)
  default = []
}
variable "public_subnet_zone" {
  type    = list(string)
  default = []
}
variable "frontend_subnet_address" {
  type    = list(string)
  default = []
}
variable "frontend_subnet_zone" {
  type    = list(string)
  default = []
}
variable "backend_subnet_address" {
  type    = list(string)
  default = []
}
variable "backend_subnet_zone" {
  type    = list(string)
  default = []
}

variable "enabled_metrics" {
  type = list(string)

  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

# EC2 instances configuration vars
variable "key_name" {}
variable "instance_type" {}
variable "aws_key_pair" {}

# DB configuraiton vars

variable "db_instance_type" {}
variable "db_username" {}
variable "db_password" {}
variable "engine" {}
variable "engine_version" {}

# Backend vars
variable "bucket_name" {}
variable "acl" {}
variable "tags" {}
