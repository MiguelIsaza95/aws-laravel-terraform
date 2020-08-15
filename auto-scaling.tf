resource "aws_autoscaling_group" "laravel" {
  depends_on = [aws_db_instance.mysql_server]
  name_prefix               = "laravel-autoscaling-group"
  max_size                  = 5
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  default_cooldown          = 300
  termination_policies      = ["Default"]
  enabled_metrics           = var.enabled_metrics
  protect_from_scale_in     = false
  load_balancers            = [aws_elb.elb_laravel.name]
  vpc_zone_identifier       = [aws_subnet.front_private.0.id, aws_subnet.front_private.1.id]
  launch_template {
    id      = aws_launch_template.laravel.id
    version = "$Latest"
  }
  force_delete = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "laravel_policy_up" {
  name                   = "laravel-scale-up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.laravel.name
}

resource "aws_autoscaling_policy" "laravel_policy_down" {
  name                   = "laravel-scale-down"
  scaling_adjustment     = -2
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.laravel.name
}