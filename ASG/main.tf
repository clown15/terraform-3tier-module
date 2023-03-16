data "aws_security_group" "albsg" {
  id = var.albsg_id
}

resource "aws_security_group" "ec2sg_web" {
  vpc_id      = var.vpc_id
  name        = "${var.company}-ec2sg-${var.env}-web-apne2"
  description = "alb sg"

  tags = {
    Name = "${var.company}-ec2sg-${var.env}-web-apne2"
  }

  ingress {
    to_port         = 80
    from_port       = 80
    protocol        = "tcp"
    security_groups = [data.aws_security_group.albsg.id]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg" {
  name             = "${var.company}-asg-${var.env}-web-apne2"
  min_size         = 1
  max_size         = 4
  desired_capacity = 1
  launch_template {
    id      = aws_launch_template.lt-web.id
    version = "$Latest"
  }
  target_group_arns = [ var.alb_tg.arn ]
  vpc_zone_identifier = var.sub_ids
  force_delete        = true
}

resource "aws_autoscaling_policy" "asg_policy" {
  name                   = "${var.company}-asg-policy-${var.env}"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

# resource "aws_autoscaling_attachment" "asg_attachment" {
#   autoscaling_group_name = aws_autoscaling_group.asg.id
#   lb_target_group_arn = var.alb_tg.arn
# }