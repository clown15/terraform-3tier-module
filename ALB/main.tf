resource "aws_security_group" "alb_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.company}-albsg-${var.env}-web-apne2"
  description = "alb sg"

  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    to_port     = 443
    from_port   = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  tags = {
    Name = "${var.company}-albsg-${var.env}-web-apne2"
  }
}

resource "aws_lb" "web_alb" {
  name               = "${var.company}-alb-${var.env}-web-apne2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.pub_sub_ids # var.pub_sub_ids는 list type

  tags = {
    Name = "${var.company}-alb-${var.env}-web-apne2"
  }
}

resource "aws_lb_target_group" "instg" {
  name     = "${var.company}-instg-${var.env}-web-apne2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

data "aws_acm_certificate" "cert" {
  domain      = var.domain
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
############ HTTPS Listener ###############
resource "aws_lb_listener" "web_lb_https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "I'm a teapot"
      status_code  = "418"
    }
  }
}

resource "aws_lb_listener_rule" "web_lb_https_rule" {
  listener_arn = aws_lb_listener.web_lb_https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instg.arn
  }

  condition {
    host_header {
      values = ["www.${var.domain}"]
    }
  }
}

############ HTTP Listener ###############
resource "aws_lb_listener" "web_lb_http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Here!"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "web_lb_http_rule" {
  listener_arn = aws_lb_listener.web_lb_http.arn
  priority     = 10

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [var.domain]
    }
  }
}

data "aws_route53_zone" "zone" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = true
  }
}