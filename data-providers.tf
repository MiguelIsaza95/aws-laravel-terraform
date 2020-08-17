data "aws_ami" "linux_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*"]
  }
}

data "aws_ami" "amz_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

data "template_file" "init" {
  template = file("${path.module}/bastion.tpl")
  vars = {
    user   = var.db_username
    passwd = var.db_password
    host   = "db.laravelaws.org"
  }
}