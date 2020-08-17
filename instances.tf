resource "aws_instance" "bastion" {
  monitoring                  = true
  ami                         = data.aws_ami.amz_latest.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.dmz_public.*.id, 0)
  user_data                   = filebase64("${path.module}/bastion.sh")
  tags = {
    Name        = "bastion"
    Environment = "Test"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "nat" {
  monitoring                  = true
  ami                         = data.aws_ami.linux_latest.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [aws_security_group.nat_sg.id]
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.dmz_public.*.id, 1)
  tags = {
    Name        = "nat"
    Environment = "Test"
  }
  lifecycle {
    create_before_destroy = true
  }
  source_dest_check = false
}

resource "aws_launch_template" "laravel" {
  monitoring {
    enabled = true
  }
  name_prefix            = "laravel"
  image_id               = data.aws_ami.centos_latest.id
  instance_type          = var.laravel_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.laravel_sg.id, aws_security_group.general_sg.id]
  user_data              = filebase64("${path.module}/laravel.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "laravel"
      Environment = "Test"
    }
  }
  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_db_instance" "mysql_server" {
  engine                = var.engine
  engine_version        = var.engine_version
  identifier            = "laravelaws"
  username              = var.db_username
  password              = var.db_password
  name                  = var.db_initial_db_name
  instance_class        = var.db_instance_type
  allocated_storage     = 20
  max_allocated_storage = 100
  multi_az              = false
  publicly_accessible   = false
  port                  = 3306
  tags = {
    Name        = "Mysql_Server"
    Environment = "Test"
  }
  vpc_security_group_ids = [aws_security_group.db_sg.id, aws_security_group.general_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.id

  parameter_group_name = aws_db_parameter_group.default.id
  skip_final_snapshot  = true
}

resource "aws_db_snapshot" "db_snapshot" {
  db_instance_identifier = aws_db_instance.mysql_server.id
  db_snapshot_identifier = "snapshot1234"
}

resource "aws_db_parameter_group" "default" {
  name   = "mysql-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = aws_subnet.back_private.*.id
}