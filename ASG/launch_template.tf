data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }
}

resource "aws_iam_instance_profile" "asg_profile" {
  name = "${var.company}-role-ec2ssm-profile"
  role = var.iam_role.name
}

resource "aws_launch_template" "lt-web" {
  name          = "${var.company}-lt-${var.env}-web-apne2"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = var.volume_type
    }
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.asg_profile.arn
  }
  vpc_security_group_ids = [aws_security_group.ec2sg_web.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.company}-ec2-${var.env}-web-apne2"
    }
  }

  user_data = filebase64("${path.module}/ec2_user_data.sh")

  tags = {
    Name = "${var.company}-lt-${var.env}-web-apne2"
  }
}