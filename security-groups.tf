resource "aws_security_group" "bastion_sg" {
  name   = "Bastion rules"
  vpc_id = aws_vpc.test.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["179.12.16.164/32"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.test.cidr_block]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  description = "Allow SSH for admin"
}

resource "aws_security_group" "nat_sg" {
  name   = "Nat rules"
  vpc_id = aws_vpc.test.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.test.cidr_block]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.test.cidr_block]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  description = "Allow instances to make updates"
}

resource "aws_security_group" "general_sg" {
  name   = "General rules"
  vpc_id = aws_vpc.test.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nat_sg.id]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.nat_sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.32.0.0/16"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.32.0.0/16"]
  }
  description = "Allow bastion and nat traffic from/to instances"
}

resource "aws_security_group" "elb_laravel_sg" {
  name   = "ELB laravel rules"
  vpc_id = aws_vpc.test.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.laravel_sg.id]
  }
}

resource "aws_security_group" "laravel_sg" {
  name        = "laravel rules"
  vpc_id      = aws_vpc.test.id
  description = "Allow http traffic to mysql server"
}

resource "aws_security_group" "db_sg" {
  name   = "DB rules"
  vpc_id = aws_vpc.test.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.laravel_sg.id, aws_security_group.bastion_sg.id]
  }
  description = "Allow mysql traffic from/to backend instances"
}
