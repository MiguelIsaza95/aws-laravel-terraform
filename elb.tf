resource "aws_elb" "elb_laravel" {
  name    = "laravel-elb"
  subnets = [aws_subnet.dmz_public.0.id, aws_subnet.dmz_public.1.id, aws_subnet.front_private.2.id]
  # subnets helps to attach the lb to your current vpc
  # we can define az or subnets, but just one of them.
  security_groups = [aws_security_group.elb_laravel_sg.id]
  internal        = false
  tags = {
    Environment = "test"
  }
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}