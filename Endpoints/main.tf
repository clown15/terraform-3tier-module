resource "aws_security_group" "epsg" {
  vpc_id = var.vpc_id

  name        = "${var.company}-epsg-${var.env}-comm-apne2"
  description = "security group for vpc endpoint"

  tags = {
    Name = "${var.company}-epsg-${var.env}-comm-apne2"
  }

  ingress {
    cidr_blocks = ["${var.vpc_cidr}"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  ingress {
    cidr_blocks = ["${var.vpc_cidr}"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.epsg.id, ]
  private_dns_enabled = true
  subnet_ids          = var.pub_sub_ids
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.epsg.id, ]
  private_dns_enabled = true
  subnet_ids          = var.pub_sub_ids
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.epsg.id, ]
  private_dns_enabled = true
  subnet_ids          = var.pub_sub_ids
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.epsg.id, ]
  private_dns_enabled = true
  subnet_ids          = var.pub_sub_ids
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.epsg.id, ]
  private_dns_enabled = true
  subnet_ids          = var.pub_sub_ids
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3ep" {
  route_table_id  = var.pri_web_rtb_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}