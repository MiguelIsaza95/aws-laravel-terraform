data "aws_ami" "linux_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*"]
  }
}

data "template_file" "script" {
  template = file("${path.module}/laravel.tpl")
  vars = {
    efs_dns = aws_efs_file_system.efs.dns_name
  }
}