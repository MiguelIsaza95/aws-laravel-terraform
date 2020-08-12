resource "aws_security_group_rule" "bastion_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion_sg.id
  source_security_group_id = aws_security_group.db_sg.id
  description              = "Allow mysql traffic from bastion to mysql server"
}

resource "aws_security_group_rule" "laravel_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.laravel_sg.id
  source_security_group_id = aws_security_group.elb_laravel_sg.id
  description              = "Allow http traffic from laravel elb"
}

resource "aws_security_group_rule" "laravel_db_egress" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.laravel_sg.id
  source_security_group_id = aws_security_group.db_sg.id
  description              = "Allow http traffic to mysql server"
}